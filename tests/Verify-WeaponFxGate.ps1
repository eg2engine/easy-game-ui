$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$gate = [IO.File]::ReadAllText((Join-Path $projectRoot 'Sephiroth\Classes\BlackGoldWeaponFxLink.uc'))
$controller = [IO.File]::ReadAllText((Join-Path $projectRoot 'Sephiroth\Classes\ClientController.uc'))
$table = [IO.File]::ReadAllText((Join-Path $projectRoot 'Sephiroth\Classes\ItemFxTable.uc'))
if ($gate -notmatch 'AffixValue < 17' -or $gate -notmatch 'Count >= 5') { throw 'Wrong gate threshold' }
if ($gate -match 'AddMessage|ShowDiagnostic') { throw 'Automatic chat diagnostics remain' }
if ($controller -match 'AddMessage\([^\r\n]*BGFX') { throw 'BGFX command still writes to chat' }
if ($table -match "ItemEffectClass=Class'Sephiroth.Designed_") { throw 'Native table bypass remains' }

# Boundary model of the compiled UnrealScript predicate; not an engine integration test.
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
    if ((Test-Eligible $case.N $case.V) -ne $case.Expected) { throw "Failed: $($case.Name)" }
    Write-Output "PASS: $($case.Name)"
}
Write-Output 'PASS: source guards and eight boundary cases; client integration remains to be verified.'

# Resolver regression model. This does not execute UnrealScript/native attachment code.
if ($gate -match 'return W.Info;') { throw 'Shallow attachment Info bypass remains' }
foreach ($guard in @('Equipped = CC.PSI.WornItems', 'H.Attachments[H.AT_BothHand]', 'IsWeaponSlot(Item.EquipPlace)', 'Candidate != None && Candidate != Item')) {
    if (-not $gate.Contains($guard)) { throw "Missing resolver guard: $guard" }
}
function Get-ModelKey([string]$name) {
    $key = ($name -split '\.')[-1].ToUpperInvariant()
    if ($key -in @('ACORDGAUNTLETHMB','ACORDGAUNTLETHFB','ACORDGAUNTLETBHM','ACORDGAUNTLETBHF')) { return 'ACORDGAUNTLETB' }
    return $key
}
function Resolve-Model($items, $weapon, $info, $slot, $mesh) {
    $hands = @($items | Where-Object { $_.Slot -in @(8,9,16) })
    foreach ($item in $hands) {
        if ($item.Model -eq $weapon -or $item.Id -eq $info) { return $item.Id }
    }
    $matching = @($hands | Where-Object { $_.Name -and (Get-ModelKey $_.Name) -eq (Get-ModelKey $mesh) })
    $bySlot = @($matching | Where-Object { $_.Slot -eq $slot })
    if ($bySlot.Count -eq 1) { return $bySlot[0].Id }
    $ids = @($matching | ForEach-Object { $_.Id } | Select-Object -Unique)
    if ($ids.Count -eq 1) { return $ids[0] }
    return $null
}
$red = @{ Id='red'; Slot=16; Model=''; Name='AblazeStaffB' }
$blue = @{ Id='blue'; Slot=8; Model=''; Name='GlaciesStickB' }
$resolverCases = @(
    @{Name='missing Info and reverse Model'; Items=@($red); Info=''; Slot=16; Mesh='HumanStaff.AblazeStaffB'; Expected='red'},
    @{Name='shallow Info does not shadow equipped data'; Items=@($red); Info='shallow'; Slot=16; Mesh='HumanStaff.AblazeStaffB'; Expected='red'},
    @{Name='two-handed render slot differs'; Items=@($red); Info=''; Slot=8; Mesh='HumanStaff.AblazeStaffB'; Expected='red'},
    @{Name='no cross-weapon borrowing'; Items=@($blue); Info=''; Slot=8; Mesh='HumanStaff.AblazeStaffB'; Expected=$null},
    @{Name='unequipped stale Info rejected'; Items=@(); Info='red'; Slot=16; Mesh='HumanStaff.AblazeStaffB'; Expected=$null},
    @{Name='non-weapon slot rejected'; Items=@(@{Id='body';Slot=2;Model='';Name='AblazeStaffB'}); Info='';Slot=-1;Mesh='HumanStaff.AblazeStaffB';Expected=$null},
    @{Name='ambiguous same-model candidates rejected';Items=@($red,@{Id='red2';Slot=9;Model='';Name='AblazeStaffB'});Info='';Slot=-1;Mesh='HumanStaff.AblazeStaffB';Expected=$null},
    @{Name='actual hand wins over second candidate';Items=@($red,@{Id='red2';Slot=9;Model='';Name='AblazeStaffB'});Info='';Slot=16;Mesh='HumanStaff.AblazeStaffB';Expected='red'},
    @{Name='male gauntlet normalized';Items=@(@{Id='fist';Slot=8;Model='';Name='AcordGauntletB'});Info='';Slot=8;Mesh='Gauntlet.AcordGauntletBHM';Expected='fist'},
    @{Name='female gauntlet normalized';Items=@(@{Id='fist';Slot=8;Model='';Name='AcordGauntletB'});Info='';Slot=8;Mesh='Gauntlet.AcordGauntletHFB';Expected='fist'},
    @{Name='model pointer identity';Items=@(@{Id='pointer';Slot=16;Model='weapon';Name=''});Info='';Slot=-1;Mesh='HumanStaff.AblazeStaffB';Expected='pointer'},
    @{Name='item pointer identity';Items=@(@{Id='info';Slot=16;Model='';Name=''});Info='info';Slot=-1;Mesh='HumanStaff.AblazeStaffB';Expected='info'}
)
foreach ($case in $resolverCases) {
    $actual = Resolve-Model $case.Items 'weapon' $case.Info $case.Slot $case.Mesh
    if ($actual -ne $case.Expected) { throw "Resolver failed: $($case.Name): $actual" }
    Write-Output "PASS: $($case.Name)"
}
