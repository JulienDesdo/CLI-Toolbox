<#
.SYNOPSIS
  Compile, simulate and launch GTKWave for a VHDL project.

.DESCRIPTION
  Given a design file (.vhd) and its testbench (.vhd), this script:
  1. Compiles the design
  2. Compiles the testbench
  3. Elaborates the testbench
  4. Runs the simulation (VCD output)
  5. Launches GTKWave (with .gtkw config if available)

.PARAMETER Design
  Path to the VHDL design file (entity/architecture).

.PARAMETER Testbench
  Path to the VHDL testbench file.

.PARAMETER StopTime
  Simulation stop time (default: 500ns).

.EXAMPLE
  .\launch-vhdl.ps1 -Design d_latch.vhd -Testbench tb_xcomp.vhd -StopTime 1us
#>

param(
    [Parameter(Mandatory=$true)][string]$Design,
    [Parameter(Mandatory=$true)][string]$Testbench,
    [string]$StopTime = "500ns"
)

# Filenames
$tbName = [System.IO.Path]::GetFileNameWithoutExtension($Testbench)
$vcdFile = "out.vcd"
$gtkwFile = "$tbName.gtkw"

Write-Host "🟢 VHDL Launcher starting..." -ForegroundColor Green

# Cleanup
Remove-Item work-obj93.cf,$vcdFile -ErrorAction SilentlyContinue

# Compile design
Write-Host "📘 Compiling design: $Design"
ghdl -a --std=93 $Design

# Compile testbench
Write-Host "📘 Compiling testbench: $Testbench"
ghdl -a --std=93 $Testbench

# Elaborate
Write-Host "⚙️  Elaborating $tbName"
ghdl -e --std=93 $tbName

# Run simulation
Write-Host "▶️  Running simulation (Stop time = $StopTime)"
ghdl -r --std=93 $tbName --vcd=$vcdFile --stop-time=$StopTime

# Launch GTKWave
if (Test-Path $gtkwFile) {
    Write-Host "👀 Opening GTKWave with $gtkwFile"
    Start-Process gtkwave -ArgumentList $vcdFile,$gtkwFile
} else {
    Write-Host "👀 Opening GTKWave (no .gtkw config found)"
    Start-Process gtkwave -ArgumentList $vcdFile
}
