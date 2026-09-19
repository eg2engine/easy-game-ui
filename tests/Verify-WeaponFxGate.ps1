param([string]$BaselineRef = '0217d87')

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$gate = [IO.File]::ReadAllText((Join-Path $projectRoot 'Sephiroth\Classes\BlackGoldWeaponFxLink.uc'))
$controller = [IO.File]::ReadAllText((Join-Path $projectRoot 'Sephiroth\Classes\ClientController.uc'))
$table = [IO.File]::ReadAllText((Join-Path $projectRoot 'Sephiroth\Classes\ItemFxTable.uc'))
$base = [IO.File]::ReadAllText((Join-Path $projectRoot 'Sephiroth\Classes\DesignedWeaponFxBase.uc'))
$blueSource = [IO.File]::ReadAllText((Join-Path $projectRoot 'Sephiroth\Classes\Designed_GlaciesStickB_Particles.uc'))
$script:assertionCount = 0

function Assert-Check([bool]$condition, [string]$message) {
    if (-not $condition) { throw $message }
    $script:assertionCount++
}

function Get-CodeOnly([string]$source) {
    return [regex]::Replace([regex]::Replace($source, '(?s)/\*.*?\*/', ''), '(?m)//[^\r\n]*', '')
}

function Get-FunctionBody([string]$source, [string]$name) {
    $pattern = '(?im)^\s*(?:(?:simulated|static|final|exec)\s+)*(?:function|event)\s+(?:\w+(?:<\w+>)?\s+)?' + [regex]::Escape($name) + '\s*\('
    $match = [regex]::Match($source, $pattern)
    if (-not $match.Success) { throw "Missing UnrealScript function: $name" }
    $start = $source.IndexOf('{', $match.Index + $match.Length)
    if ($start -lt 0) { throw "Missing function body: $name" }
    $depth = 1
    for ($index = $start + 1; $index -lt $source.Length; $index++) {
        if ($source[$index] -eq '{') { $depth++ }
        if ($source[$index] -eq '}') { $depth-- }
        if ($depth -eq 0) { return $source.Substring($start + 1, $index - $start - 1) }
    }
    throw "Unterminated function body: $name"
}

function Get-DefaultProperties([string]$source) {
    $match = [regex]::Match($source, '(?is)\bdefaultproperties\s*\{.*\z')
    if (-not $match.Success) { throw 'Missing defaultproperties block' }
    return $match.Value.Replace("`r`n", "`n").Trim()
}

function Get-BaselineText([string]$path) {
    $result = & git -C $projectRoot show "${BaselineRef}:$path"
    if ($LASTEXITCODE -ne 0) { throw "Cannot read $path from baseline $BaselineRef" }
    return ($result -join "`n").TrimEnd()
}

# Source invariants and independent PowerShell models below do not execute
# UnrealScript, native objects, the renderer, or the client login sequence.
if ($gate -notmatch 'AffixValue < 17' -or $gate -notmatch 'Count >= 5') { throw 'Wrong gate threshold' }
if ($gate -match 'AddMessage|ShowDiagnostic') { throw 'Automatic chat diagnostics remain' }
if ($controller -match 'AddMessage\([^\r\n]*BGFX') { throw 'BGFX command still writes to chat' }
if ($table -match "ItemEffectClass=Class'Sephiroth.Designed_") { throw 'Native table bypass remains' }

# Boundary model of the intended UnrealScript predicate; not an engine test.
function Test-Eligible($names, $levels) {
    $qualified = @{}
    for ($i = 0; $i -lt $levels.Count; $i++) {
        if ($names[$i] -ne '' -and $levels[$i] -ge 17) { $qualified[$names[$i].ToUpperInvariant()] = $true }
    }
    return $qualified.Count -ge 5
}
$cases = @(
    @{Name='no attributes'; N=@(); V=@(); Expected=$false},
    @{Name='four at 17'; N=@('a','b','c','d'); V=@(17,17,17,17); Expected=$false},
    @{Name='five at 17'; N=@('a','b','c','d','e'); V=@(17,17,17,17,17); Expected=$true},
    @{Name='one below 17'; N=@('a','b','c','d','e'); V=@(17,17,17,17,16); Expected=$false},
    @{Name='five qualifying of six'; N=@('a','b','c','d','e','f'); V=@(17,17,17,17,18,1); Expected=$true},
    @{Name='five above 17'; N=@('a','b','c','d','e'); V=@(18,18,19,20,20); Expected=$true},
    @{Name='duplicate must not count twice'; N=@('a','b','c','d','A'); V=@(17,17,17,17,17); Expected=$false},
    @{Name='missing name'; N=@('a','b','c','d',''); V=@(17,17,17,17,17); Expected=$false}
)
foreach ($case in $cases) {
    Assert-Check ((Test-Eligible $case.N $case.V) -eq $case.Expected) "Eligibility model failed: $($case.Name)"
}
Write-Output 'PASS: original eight eligibility boundaries.'

# Resolver regression model. This does not execute UnrealScript/native attachment code.
if ($gate -match 'return W.Info;') { throw 'Shallow attachment Info bypass remains' }
function Get-ModelKey([string]$name) {
    $key = ($name -split '\.')[-1].ToUpperInvariant()
    if ($key -eq 'NONE') { return '' }
    if ($key -in @('ACORDGAUNTLETHMB','ACORDGAUNTLETHFB','ACORDGAUNTLETBHM','ACORDGAUNTLETBHF')) { return 'ACORDGAUNTLETB' }
    return $key
}
function Test-ModelMatch($item, [string]$mesh, [string]$staticMesh) {
    if ($null -eq $item) { return $false }
    $key = Get-ModelKey $item.Name
    if (-not $key) { return $false }
    return ($mesh -and $key -eq (Get-ModelKey $mesh)) -or ($staticMesh -and $key -eq (Get-ModelKey $staticMesh))
}

function Resolve-Model($items, [string]$weapon, [string]$info, [string]$mount, [string]$mesh, [string]$staticMesh, [bool]$isGauntlet = $false, [bool]$ready = $true) {
    if (-not $ready -or $mount -notin @('Right','Left','Both','LeftFist','RightFist')) { return $null }
    $fist = $mount -in @('LeftFist','RightFist')
    if ($fist -and -not $isGauntlet) { return $null }
    $hands = @($items | Where-Object { $null -ne $_ -and $_.Slot -in @(8,9,16) -and (-not $fist -or $_.DetailType -eq 10) })
    $identities = @($hands | Where-Object { $_.Model -eq $weapon -or ($info -and $_.Id -eq $info) } | ForEach-Object { $_.Id } | Select-Object -Unique)
    if ($identities.Count -gt 1) { return $null }
    if ($identities.Count -eq 1) { return $identities[0] }
    if ($fist) { return $null }
    $slot = @{Right=8;Left=9;Both=16}[$mount]
    $matching = @($hands | Where-Object { Test-ModelMatch $_ $mesh $staticMesh })
    $bySlot = @($matching | Where-Object { $_.Slot -eq $slot } | ForEach-Object { $_.Id } | Select-Object -Unique)
    if ($bySlot.Count -gt 1) { return $null }
    if ($bySlot.Count -eq 1) { return $bySlot[0] }
    if ($mount -ne 'Both') { return $null }
    $bothHand = @($matching | Where-Object { $_.Slot -eq 8 -and ($_.AttachPlace -band 0x100) -ne 0 } | ForEach-Object { $_.Id } | Select-Object -Unique)
    if ($bothHand.Count -eq 1) { return $bothHand[0] }
    return $null
}
$red = @{Id='red';Slot=16;Model='';Name='AblazeStaffB';AttachPlace=0x100;DetailType=11}
$blue = @{Id='blue';Slot=8;Model='';Name='GlaciesStickB';AttachPlace=0x100;DetailType=38}
$resolverCases = @(
    @{Name='missing Info and reverse Model';Items=@($red);Mount='Both';Mesh='HumanStaff.AblazeStaffB';Expected='red'},
    @{Name='shallow Info does not shadow equipped data';Items=@($red);Info='shallow';Mount='Both';Mesh='HumanStaff.AblazeStaffB';Expected='red'},
    @{Name='known both-hand to equipment right mapping';Items=@($blue);Mount='Both';Mesh='GlaciesStickB';Expected='blue'},
    @{Name='reverse cross-slot mapping is not guessed';Items=@($red);Mount='Right';Mesh='AblazeStaffB';Expected=$null},
    @{Name='left hand cannot borrow equipment right';Items=@($blue);Mount='Left';Mesh='GlaciesStickB';Expected=$null},
    @{Name='right hand cannot borrow equipment left';Items=@(@{Id='left';Slot=9;Name='GlaciesStickB'});Mount='Right';Mesh='GlaciesStickB';Expected=$null},
    @{Name='unknown double-hand attach mask rejected';Items=@(@{Id='unknown';Slot=8;Name='GlaciesStickB';AttachPlace=0});Mount='Both';Mesh='GlaciesStickB';Expected=$null},
    @{Name='missing double-hand attach mask rejected';Items=@(@{Id='missing';Slot=8;Name='GlaciesStickB'});Mount='Both';Mesh='GlaciesStickB';Expected=$null},
    @{Name='no cross-weapon borrowing';Items=@($blue);Mount='Right';Mesh='AblazeStaffB';Expected=$null},
    @{Name='unequipped stale Info rejected';Items=@();Info='red';Mount='Both';Mesh='AblazeStaffB';Expected=$null},
    @{Name='non-weapon equipment slot rejected';Items=@(@{Id='body';Slot=2;Model='weapon';Name='AblazeStaffB'});Mount='Right';Mesh='AblazeStaffB';Expected=$null},
    @{Name='non-hand mount rejected even with identity';Items=@(@{Id='identity';Slot=8;Model='weapon';Name='GlaciesStickB'});Mount='Head';Mesh='GlaciesStickB';Expected=$null},
    @{Name='not-yet-mounted rejected even with Info';Items=@($red);Info='red';Mount='Pending';Mesh='AblazeStaffB';Expected=$null},
    @{Name='duplicate slot candidates rejected';Items=@($red,@{Id='red2';Slot=16;Name='AblazeStaffB'});Mount='Both';Mesh='AblazeStaffB';Expected=$null},
    @{Name='duplicate references to same item accepted';Items=@($red,$red);Mount='Both';Mesh='AblazeStaffB';Expected='red'},
    @{Name='actual hand wins over other matching slot';Items=@($red,@{Id='red2';Slot=9;Name='AblazeStaffB'});Mount='Both';Mesh='AblazeStaffB';Expected='red'},
    @{Name='ambiguous mapped double-hand items rejected';Items=@($blue,@{Id='blue2';Slot=8;Name='GlaciesStickB';AttachPlace=0x100});Mount='Both';Mesh='GlaciesStickB';Expected=$null},
    @{Name='model identity permits current mount with different equipment slot';Items=@(@{Id='pointer';Slot=16;Model='weapon';Name=''});Mount='Right';Mesh='AblazeStaffB';Expected='pointer'},
    @{Name='Info identity permits current mounted item';Items=@($red);Info='red';Mount='Right';Mesh='AblazeStaffB';Expected='red'},
    @{Name='conflicting object identities rejected';Items=@(@{Id='a';Slot=8;Model='weapon'},@{Id='b';Slot=9;Model='weapon'});Mount='Right';Expected=$null},
    @{Name='null list entry skipped';Items=@($null,$blue);Mount='Right';Mesh='GlaciesStickB';Expected='blue'},
    @{Name='empty model cannot guess item';Items=@(@{Id='empty';Slot=8;Name=''});Mount='Right';Mesh='GlaciesStickB';Expected=$null},
    @{Name='static-mesh-only attachment';Items=@($blue);Mount='Right';StaticMesh='Package.GlaciesStickB';Expected='blue'},
    @{Name='male gauntlet normalized';Items=@(@{Id='fist';Slot=8;Name='AcordGauntletB'});Mount='Right';Mesh='Gauntlet.AcordGauntletBHM';Expected='fist'},
    @{Name='female gauntlet normalized';Items=@(@{Id='fist';Slot=8;Name='AcordGauntletB'});Mount='Right';Mesh='Gauntlet.AcordGauntletHFB';Expected='fist'},
    @{Name='real fist association accepted';Items=@(@{Id='fist';Slot=8;Model='weapon';Name='AcordGauntletB';DetailType=10});Mount='LeftFist';Mesh='AcordGauntletHMB';Gauntlet=$true;Expected='fist'},
    @{Name='fist Info association accepted';Items=@(@{Id='fist';Slot=8;Name='AcordGauntletB';DetailType=10});Info='fist';Mount='RightFist';Mesh='AcordGauntletBHF';Gauntlet=$true;Expected='fist'},
    @{Name='fist cannot borrow unique same-model item';Items=@(@{Id='fist';Slot=8;Name='AcordGauntletB';DetailType=10});Mount='LeftFist';Mesh='AcordGauntletHMB';Gauntlet=$true;Expected=$null},
    @{Name='fist requires Gauntlet actor';Items=@(@{Id='fist';Slot=8;Model='weapon';DetailType=10});Mount='LeftFist';Expected=$null},
    @{Name='fist requires glove item type';Items=@(@{Id='fist';Slot=8;Model='weapon';DetailType=11});Mount='RightFist';Gauntlet=$true;Expected=$null},
    @{Name='unready holder does not resolve';Items=@($blue);Mount='Right';Mesh='GlaciesStickB';Unready=$true;Expected=$null}
)
foreach ($case in $resolverCases) {
    $actual = Resolve-Model $case.Items 'weapon' $case.Info $case.Mount $case.Mesh $case.StaticMesh ([bool]$case.Gauntlet) (-not $case.Unready)
    Assert-Check ($actual -eq $case.Expected) "Resolver model failed: $($case.Name); actual=$actual"
}
$pending = Resolve-Model @($blue) 'weapon' '' 'Pending' '' ''
$ready = Resolve-Model @($blue) 'weapon' '' 'Right' 'GlaciesStickB' ''
Assert-Check ($null -eq $pending -and $ready -eq 'blue') 'Delayed mounting must recover without recreating the weapon'
Write-Output "PASS: $($resolverCases.Count) resolver cases and delayed-mount recovery model."

# Resolve first, then evaluate only that item's affixes. Same model names on the
# other hand must not let a qualifying neighbour supply this weapon's gate.
$lowRight = @{Id='right';Slot=8;Name='GlaciesStickB';N=@('a','b','c','d','e');V=@(17,17,17,17,16)}
$highLeft = @{Id='left';Slot=9;Name='GlaciesStickB';N=@('a','b','c','d','e');V=@(17,17,17,17,17)}
$highRight = @{Id='right';Slot=8;Name='GlaciesStickB';N=@('a','b','c','d','e');V=@(17,17,17,17,17)}
$lowLeft = @{Id='left';Slot=9;Name='GlaciesStickB';N=@('a','b','c','d','e');V=@(17,17,17,17,16)}
$combinedCases = @(
    @{Name='low right cannot use qualifying left';Items=@($lowRight,$highLeft);Mount='Right';Expected=$false},
    @{Name='qualifying left uses its own affixes';Items=@($lowRight,$highLeft);Mount='Left';Expected=$true},
    @{Name='low left cannot use qualifying right';Items=@($highRight,$lowLeft);Mount='Left';Expected=$false},
    @{Name='qualifying right uses its own affixes';Items=@($highRight,$lowLeft);Mount='Right';Expected=$true},
    @{Name='missing right cannot borrow qualifying left';Items=@($highLeft);Mount='Right';Expected=$false},
    @{Name='missing left cannot borrow qualifying right';Items=@($highRight);Mount='Left';Expected=$false}
)
foreach ($case in $combinedCases) {
    $resolved = Resolve-Model $case.Items 'weapon' '' $case.Mount 'GlaciesStickB' ''
    $selected = @($case.Items | Where-Object { $_.Id -eq $resolved })
    $eligible = $selected.Count -eq 1 -and (Test-Eligible $selected[0].N $selected[0].V)
    Assert-Check ($eligible -eq $case.Expected) "Resolve-to-gate model failed: $($case.Name)"
}
Write-Output "PASS: $($combinedCases.Count) combined same-model/different-affix hand cases."

function Get-EffectModel([string]$itemName, [string]$mesh, [string]$staticMesh, [bool]$isMale) {
    $allowed = @('MURCIELSWORDB','ABLAZESTAFFB','GLACIESSTICKB','APLITEBOWB','ACORDGAUNTLETB')
    $actual = @(@($mesh,$staticMesh) | ForEach-Object { Get-ModelKey $_ } | Where-Object { $_ })
    if ($actual.Count -eq 0) { return $null }
    $key = Get-ModelKey $itemName
    if (-not $key) { $key = $actual[0] }
    if ($key -notin $allowed -or @($actual | Where-Object { $_ -ne $key }).Count -gt 0) { return $null }
    if ($key -ne 'ACORDGAUNTLETB') { return $key }
    $variants = @(@($mesh,$staticMesh) | ForEach-Object {
        $raw = ($_ -split '\.')[-1].ToUpperInvariant()
        if ($raw -in @('ACORDGAUNTLETHMB','ACORDGAUNTLETBHM')) { 'HM' }
        if ($raw -in @('ACORDGAUNTLETHFB','ACORDGAUNTLETBHF')) { 'HF' }
    } | Select-Object -Unique)
    if ($variants.Count -gt 1) { return $null }
    if ($variants.Count -eq 1) { return 'ACORDGAUNTLET' + $variants[0] }
    if ($isMale) { return 'ACORDGAUNTLETHM' }
    return 'ACORDGAUNTLETHF'
}
$effectCases = @(
    @{Name='blue exact case-insensitive model';Item='Items.glaciesstickb';Mesh='Weapons.GlaciesStickB';Expected='GLACIESSTICKB'},
    @{Name='red model';Item='AblazeStaffB';Mesh='AblazeStaffB';Expected='ABLAZESTAFFB'},
    @{Name='sword model';Item='MurcielSwordB';Mesh='MurcielSwordB';Expected='MURCIELSWORDB'},
    @{Name='bow model';Item='ApliteBowB';Mesh='ApliteBowB';Expected='APLITEBOWB'},
    @{Name='item name cannot replace missing actual model';Item='GlaciesStickB';Expected=$null},
    @{Name='empty item name uses actual mesh';Mesh='GlaciesStickB';Expected='GLACIESSTICKB'},
    @{Name='empty item name uses actual static mesh';StaticMesh='GlaciesStickB';Expected='GLACIESSTICKB'},
    @{Name='all model data missing';Expected=$null},
    @{Name='None names treated as missing';Item='None';Mesh='None';Expected=$null},
    @{Name='substring suffix rejected';Item='GlaciesStickB_Experimental';Mesh='GlaciesStickB_Experimental';Expected=$null},
    @{Name='substring prefix rejected';Item='FakeGlaciesStickB';Mesh='FakeGlaciesStickB';Expected=$null},
    @{Name='valid item conflicting actual model rejected';Item='GlaciesStickB';Mesh='AblazeStaffB';Expected=$null},
    @{Name='valid mesh cannot override ordinary item name';Item='OrdinaryStaff';Mesh='GlaciesStickB';Expected=$null},
    @{Name='mesh-static conflict rejected';Mesh='GlaciesStickB';StaticMesh='AblazeStaffB';Expected=$null},
    @{Name='HF actual variant beats male PSI';Item='AcordGauntletB';Mesh='AcordGauntletHFB';Male=$true;Expected='ACORDGAUNTLETHF'},
    @{Name='BHF alternate variant';Item='AcordGauntletB';Mesh='AcordGauntletBHF';Expected='ACORDGAUNTLETHF'},
    @{Name='HM actual variant beats female PSI';Item='AcordGauntletB';Mesh='AcordGauntletHMB';Expected='ACORDGAUNTLETHM'},
    @{Name='BHM alternate variant';Item='AcordGauntletB';Mesh='AcordGauntletBHM';Expected='ACORDGAUNTLETHM'},
    @{Name='generic gauntlet uses male PSI';Item='AcordGauntletB';Mesh='AcordGauntletB';Male=$true;Expected='ACORDGAUNTLETHM'},
    @{Name='generic gauntlet uses female PSI';Item='AcordGauntletB';Mesh='AcordGauntletB';Expected='ACORDGAUNTLETHF'},
    @{Name='conflicting actual gender variants rejected';Item='AcordGauntletB';Mesh='AcordGauntletHMB';StaticMesh='AcordGauntletHFB';Expected=$null}
)
foreach ($case in $effectCases) {
    # Hashtable.Item is also an indexer; use key syntax when the key is absent.
    $actual = Get-EffectModel ($case['Item']) $case.Mesh $case.StaticMesh ([bool]$case.Male)
    Assert-Check ($actual -eq $case.Expected) "Effect model failed: $($case.Name); actual=$actual"
}
Write-Output "PASS: $($effectCases.Count) exact-model and gender-selection cases."

function New-RecoveryModel {
    return @{Eligible=$true;Destroyed=$false;Delay=0.5;Next=0.0;Visual=$false;Detail=$false;Blocked=@{};Reports=0}
}
function Test-CanAttempt($state, [double]$now, [string]$detailClass) {
    return $state.Eligible -and -not $state.Destroyed -and -not $state.Blocked.ContainsKey($detailClass) -and $now -ge $state.Next
}
function Set-RecoveryFailure($state, [double]$now) {
    $state.Next = $now + $state.Delay
    $state.Delay = [Math]::Min(2.0, $state.Delay * 2.0)
}
function Set-RecoverySuccess($state) {
    $state.Visual = $true
    $state.Detail = $true
    $state.Delay = 0.5
    $state.Next = 0.0
}
function Clear-RecoveryModel($state) {
    $state.Eligible = $false
    $state.Visual = $false
    $state.Detail = $false
    $state.Delay = 0.5
    $state.Next = 0.0
}
function Set-StructureFailure($state, [string]$detailClass) {
    if (-not $state.Blocked.ContainsKey($detailClass)) {
        $state.Blocked[$detailClass] = $true
        $state.Reports++
    }
}
$recovery = New-RecoveryModel
$now = 0.0
foreach ($interval in @(0.5,1.0,2.0,2.0,2.0)) {
    Assert-Check (Test-CanAttempt $recovery $now 'Blue') 'An eligible retry must run at its deadline'
    Set-RecoveryFailure $recovery $now
    Assert-Check ([Math]::Abs($recovery.Next - $now - $interval) -lt 0.0001) 'Retry delays must be 0.5/1/2 seconds, capped at 2'
    Assert-Check (-not (Test-CanAttempt $recovery ($recovery.Next - 0.001) 'Blue')) 'Do not retry every frame before deadline'
    $now = $recovery.Next
}
Set-RecoverySuccess $recovery
Assert-Check ($recovery.Delay -eq 0.5 -and $recovery.Visual -and $recovery.Detail) 'Successful creation resets recovery backoff'
$recovery.Detail = $false
Set-RecoveryFailure $recovery $now
Assert-Check ($recovery.Next -eq $now + 0.5) 'Later particle loss restarts at the shortest retry delay'
Clear-RecoveryModel $recovery
Assert-Check (-not (Test-CanAttempt $recovery ($now + 100) 'Blue') -and -not $recovery.Visual -and -not $recovery.Detail) 'Unequip cancels recovery and clears visuals'
$recovery.Eligible = $true
# The invalid-class latch is recorded immediately when validation fails, before
# a later Link tick can clear/replace the Visual during an equipment transition.
Set-StructureFailure $recovery 'Blue'
Set-StructureFailure $recovery 'Blue'
Assert-Check ($recovery.Blocked.Count -eq 1 -and $recovery.Reports -eq 1) 'Repeated structural reports must create only one class record/report'
Assert-Check (-not (Test-CanAttempt $recovery ($now + 100) 'Blue')) 'Structural failure blocks repeated creation of that class'
Clear-RecoveryModel $recovery
$recovery.Eligible = $true
Assert-Check (-not (Test-CanAttempt $recovery ($now + 100) 'Blue')) 'Validation failure followed by unequip before Link tick must preserve the class latch'
Assert-Check (Test-CanAttempt $recovery ($now + 100) 'Red') 'One bad detail class must not disable other classes'
Set-RecoverySuccess $recovery
Clear-RecoveryModel $recovery
$recovery.Eligible = $true
Assert-Check (-not (Test-CanAttempt $recovery ($now + 100) 'Blue')) 'Switching to another class and back must not clear the original class latch'
$recovery.Destroyed = $true
Assert-Check (-not (Test-CanAttempt $recovery ($now + 100) 'Red')) 'Destroyed weapon/link cannot retry'
foreach ($failureKind in @('initial visual Spawn failure','particle loss','visual loss')) {
    $failureState = New-RecoveryModel
    if ($failureKind -ne 'initial visual Spawn failure') { Set-RecoverySuccess $failureState }
    if ($failureKind -eq 'particle loss') { $failureState.Detail = $false }
    if ($failureKind -eq 'visual loss') { $failureState.Visual = $false; $failureState.Detail = $false }
    Set-RecoveryFailure $failureState 10.0
    Assert-Check (-not (Test-CanAttempt $failureState 10.499 'Blue')) "$failureKind must wait before retry"
    Assert-Check (Test-CanAttempt $failureState 10.5 'Blue') "$failureKind must be eligible to retry after 0.5s"
    Set-RecoverySuccess $failureState
    Assert-Check ($failureState.Visual -and $failureState.Detail -and $failureState.Delay -eq 0.5) "$failureKind must recover to the ready state"
    Clear-RecoveryModel $failureState
    $cleared = $failureState | ConvertTo-Json -Compress
    Clear-RecoveryModel $failureState
    Assert-Check (($failureState | ConvertTo-Json -Compress) -ceq $cleared) 'Repeated cleanup must be idempotent'
}
Write-Output 'PASS: bounded retry, reset, cancellation, and immediate per-class structural lockout models.'

function Test-BlueStructure($emitters, [int]$trailColorCount) {
    if ($emitters.Count -lt 25) { return $false }
    foreach ($index in @(2,3,5,10,11,15,16,17,18,23,24)) {
        if ($null -eq $emitters[$index]) { return $false }
    }
    return $trailColorCount -ge 1
}
Assert-Check (Test-BlueStructure @(0..24) 1) 'Complete blue structure should validate'
Assert-Check (-not (Test-BlueStructure @(0..23) 1)) 'Short blue emitter array must fail validation'
Assert-Check (-not (Test-BlueStructure @(0..24) 0)) 'Empty trail color scale must fail validation'
foreach ($index in @(2,3,5,10,11,15,16,17,18,23,24)) {
    $emitters = @(0..24)
    $emitters[$index] = $null
    Assert-Check (-not (Test-BlueStructure $emitters 1)) "Missing blue emitter $index must fail validation"
}
Write-Output 'PASS: blue particle structure boundary models.'

$gateCode = Get-CodeOnly $gate
$resolverCode = Get-FunctionBody $gateCode 'ResolveItem'
$effectCode = Get-FunctionBody $gateCode 'EffectClassFor'
$mountCode = (Get-FunctionBody $gateCode 'GetMountSlot') + (Get-FunctionBody $gateCode 'IsFistMount')
$traceCode = Get-FunctionBody $gateCode 'TraceStage'
$linkTick = Get-FunctionBody $gateCode 'Tick'
$blueTick = Get-FunctionBody (Get-CodeOnly $blueSource) 'Tick'
$blueValidation = Get-FunctionBody (Get-CodeOnly $blueSource) 'ValidateStructure'
Assert-Check ($resolverCode -notmatch '\.FindItem\s*\(') 'Resolver must tolerate null entries without FindItem'
Assert-Check ($resolverCode -match '\bGetMountSlot\s*\(') 'Resolver must validate current mounting'
Assert-Check ($resolverCode.IndexOf('GetMountSlot') -lt $resolverCode.IndexOf('CC.PSI.WornItems')) 'Mount identity must precede equipment access'
foreach ($slot in @('AT_RightHand', 'AT_LeftHand', 'AT_BothHand', 'AT_LeftFist', 'AT_RightFist')) {
    Assert-Check ($mountCode.Contains($slot)) "Missing explicit mount classification: $slot"
}
Assert-Check ($mountCode -match '\bGauntlet\s*\(') 'Fist mounts need a gauntlet restriction'
Assert-Check ($effectCode -notmatch '\bInStr\s*\(') 'Effect selection must use exact canonical names, not substrings'
Assert-Check ($linkTick.IndexOf('HasRequiredAffixes') -lt $linkTick.IndexOf('EffectClassFor')) 'Eligibility must be checked before effect-class/model selection'
Assert-Check ($linkTick -match 'CheckDelay\s*=\s*0\.75\s*;' -and $linkTick -match 'CheckDelay\s*=\s*0\.25\s*;') 'Missing separate waiting and active poll intervals'
Assert-Check ($traceCode -match 'if\s*\(\s*!bDebugTrace\s*\)' -and $traceCode -match '\bLog\s*\(') 'TraceStage needs an explicit debug enable guard'
Assert-Check ((Get-DefaultProperties $gate) -match '\bbDebugTrace\s*=\s*False\b') 'Diagnostics must be disabled by default'
foreach ($name in @('TraceStage','SetStatus','ReportToLog')) {
    $diagnosticCode = Get-FunctionBody $gateCode $name
    Assert-Check ($diagnosticCode -notmatch 'string\s*\(') "Whole UObject conversion must not enter $name diagnostics"
    Assert-Check ($diagnosticCode -notmatch '\.(?:Mesh|StaticMesh|Base|ModelName|Affixes|WornItems)\b') "Diagnostic method $name must not traverse model/equipment data"
}
foreach ($call in [regex]::Matches($gateCode, "(?m)^\s*TraceStage\s*\(([^\r\n;]*)")) {
    Assert-Check ($call.Groups[1].Value -match "^\s*'[A-Za-z0-9_]+'\s*(?:,|\))") 'TraceStage call must start with a constant name'
}
Assert-Check ($base -match '\bEnsureDetailFx\s*\(' -and $base -match '\bbDetailStructureInvalid\b') 'Missing recoverable particle creation/invalid-structure signal'
Assert-Check ((Get-FunctionBody (Get-CodeOnly $base) 'Tick') -notmatch '\b(?:Spawn|EnsureDetailFx)\s*\(') 'Visual Tick must not bypass particle retry backoff'
Assert-Check ($gateCode -match '\bbDetailStructureInvalid\b') 'Link must observe particle structural failures'
Assert-Check ((Get-FunctionBody $gateCode 'ResetActive') -notmatch 'InvalidDetailClasses\s*(?:=|\.)') 'Normal cleanup must preserve blocked detail classes'
Assert-Check ($blueValidation -match '\bMarkDetailStructureInvalid\s*\(') 'Blue structural failure must immediately propagate to its owner'
Assert-Check ((Get-FunctionBody (Get-CodeOnly $base) 'MarkDetailStructureInvalid') -match '\bRememberInvalidDetail\s*\(') 'Structural failure must immediately latch in Link before any cleanup'
Assert-Check ((Get-FunctionBody $gateCode 'RememberInvalidDetail') -notmatch '\b(?:ClearVisual|Destroy|BlockDetail)\s*\(') 'Immediate invalid-class recording must not recursively destroy actors'
Assert-Check ($blueTick.IndexOf('ValidateStructure') -ge 0) 'Blue Tick needs structure validation'
$firstEmitterAccess = $blueTick.IndexOf('Emitters[')
Assert-Check ($firstEmitterAccess -lt 0 -or $blueTick.IndexOf('ValidateStructure') -lt $firstEmitterAccess) 'Blue Tick uses emitters before validation'
Assert-Check ($blueValidation -match 'Emitters\.Length\s*<\s*25') 'Blue structure needs at least 25 emitters'
foreach ($index in @(2,3,5,10,11,15,16,17,18,23,24)) {
    Assert-Check ($blueValidation -match ('Emitters\s*\[\s*' + $index + '\s*\]\s*==\s*None')) "Missing blue emitter guard: $index"
}
Assert-Check ($blueValidation -match 'Emitters\s*\[\s*23\s*\]\.ColorScale\.Length\s*<\s*1') 'Blue trail ColorScale[0] needs a length guard'

# Inspect the actual default subobjects, not just a mirror of their intended shape.
$blueDefaults = Get-DefaultProperties $blueSource
$bindings = @{}
foreach ($binding in [regex]::Matches($blueDefaults, "(?im)^\s*Emitters\((\d+)\)\s*=\s*SpriteEmitter'([^']+)'")) {
    $slot = [int]$binding.Groups[1].Value
    Assert-Check (-not $bindings.ContainsKey($slot)) "Duplicate default emitter binding: $slot"
    $bindings[$slot] = $binding.Groups[2].Value
}
$subobjects = @{}
foreach ($object in [regex]::Matches($blueDefaults, '(?ims)^\s*Begin Object Class=SpriteEmitter Name=(\w+)\s*(.*?)^\s*End Object')) {
    $subobjects[$object.Groups[1].Value] = $object.Groups[2].Value
}
Assert-Check ($bindings.Count -eq 25) 'Approved blue defaults must bind exactly 25 particle slots'
foreach ($slot in 0..24) {
    Assert-Check ($bindings.ContainsKey($slot) -and $subobjects.ContainsKey($bindings[$slot])) "Unresolved default particle subobject at slot $slot"
}
Assert-Check ($subobjects[$bindings[23]] -match '\bColorScale\(0\)\s*=') 'Actual trail default subobject is missing ColorScale(0)'
$literalIndices = @([regex]::Matches($blueTick, 'Emitters\s*\[\s*(\d+)\s*\]') | ForEach-Object { [int]$_.Groups[1].Value } | Select-Object -Unique)
foreach ($slot in $literalIndices) {
    Assert-Check ($bindings.ContainsKey($slot) -and $blueValidation -match ('Emitters\s*\[\s*' + $slot + '\s*\]\s*==\s*None')) "Tick particle access has no matching binding/guard: $slot"
}
Assert-Check ($blueTick -match 'for\s*\(\s*I\s*=\s*10\s*;\s*I\s*<=\s*11\s*;\s*I\+\+\s*\)') 'Re-audit dynamic emitter indices when the blue orbit loop changes'
foreach ($access in [regex]::Matches($blueTick, 'Emitters\s*\[\s*([^\]]+)\s*\]')) {
    Assert-Check ($access.Groups[1].Value.Trim() -match '^(?:\d+|I)$') 'Unexpected dynamic emitter index needs explicit range checks'
}
Write-Output 'PASS: resolver, diagnostic, recovery, and particle source guards.'

# Preserve native ABI and approved visuals against a specific, reviewable baseline.
& git -C $projectRoot rev-parse --verify "${BaselineRef}^{commit}" *> $null
if ($LASTEXITCODE -ne 0) { throw "Unknown baseline commit: $BaselineRef" }
$changedPaths = @(& git -C $projectRoot diff --name-only $BaselineRef -- '*.uc')
if ($LASTEXITCODE -ne 0) { throw 'Cannot inspect source changes against the baseline' }
foreach ($path in $changedPaths) {
    $baselineSource = Get-BaselineText $path
    $currentPath = Join-Path $projectRoot $path
    if (-not (Test-Path -LiteralPath $currentPath)) { throw "Source removed since baseline: $path" }
    $currentSource = [IO.File]::ReadAllText($currentPath)
    if ((Get-CodeOnly $baselineSource) -match '(?is)^\s*class\b[^;]*\bnative\b' -or (Get-CodeOnly $currentSource) -match '(?is)^\s*class\b[^;]*\bnative\b') {
        Assert-Check ($currentSource.Replace("`r`n", "`n").TrimEnd() -ceq $baselineSource) "Native source changed: $path"
    }
}
$visualPaths = @(& git -C $projectRoot ls-tree -r --name-only $BaselineRef -- 'Sephiroth/Classes') | Where-Object { $_ -match '/Designed_.+\.uc$' }
if ($LASTEXITCODE -ne 0) { throw 'Cannot enumerate baseline visual classes' }
Assert-Check ($visualPaths.Count -gt 0) 'No baseline visual classes found'
foreach ($path in $visualPaths) {
    $baselineSource = Get-BaselineText $path
    $currentSource = [IO.File]::ReadAllText((Join-Path $projectRoot $path))
    if ($path -eq 'Sephiroth/Classes/Designed_GlaciesStickB_Particles.uc') {
        Assert-Check ((Get-DefaultProperties $currentSource) -ceq (Get-DefaultProperties $baselineSource)) 'Approved blue particle defaultproperties changed'
    } else {
        Assert-Check ($currentSource.Replace("`r`n", "`n").TrimEnd() -ceq $baselineSource) "Unrelated approved visual changed: $path"
    }
}
Assert-Check ((Get-DefaultProperties $base) -ceq (Get-DefaultProperties (Get-BaselineText 'Sephiroth/Classes/DesignedWeaponFxBase.uc'))) 'Approved shared effect defaultproperties changed'
foreach ($path in @('Sephiroth/Classes/BlackGoldWeaponFxLink.uc','Sephiroth/Classes/DesignedWeaponFxBase.uc','Sephiroth/Classes/Designed_GlaciesStickB_Particles.uc')) {
    $baselineSource = Get-CodeOnly (Get-BaselineText $path)
    $currentSource = Get-CodeOnly ([IO.File]::ReadAllText((Join-Path $projectRoot $path)))
    $oldDeclarations = @([regex]::Matches($baselineSource, '(?im)^\s*var\b[^;]*;') | ForEach-Object { [regex]::Replace($_.Value.Trim(), '\s+', ' ') })
    $newDeclarations = @([regex]::Matches($currentSource, '(?im)^\s*var\b[^;]*;') | ForEach-Object { [regex]::Replace($_.Value.Trim(), '\s+', ' ') })
    Assert-Check ($newDeclarations.Count -ge $oldDeclarations.Count) "Existing script fields removed: $path"
    for ($index = 0; $index -lt $oldDeclarations.Count; $index++) {
        Assert-Check ($newDeclarations[$index] -ceq $oldDeclarations[$index]) "Existing script field type/order changed or new field inserted at index $index in $path"
    }
}
Assert-Check ($table.Replace("`r`n", "`n").TrimEnd() -ceq (Get-BaselineText 'Sephiroth/Classes/ItemFxTable.uc')) 'Native effect table changed'
Write-Output "PASS: native source and approved visual invariants against $BaselineRef."
Write-Output "PASS: $script:assertionCount source/model assertions. This is not UnrealScript execution or client login/crash verification."
