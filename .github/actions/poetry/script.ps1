param(
    # installed path
    [Parameter(Mandatory = $true)][string]$installed_path,
    # poetry version
    [Parameter(Mandatory = $true)][string]$version_to_install, # = "latest" by default
    # python executable
    [Parameter(Mandatory = $true)][string]$python_exe # = "python" by default
)

# set poetry_home so poetry knows where to install
[System.Environment]::SetEnvironmentVariable("POETRY_HOME", $installed_path)

$temp_installer_file = New-TemporaryFile
# get the installer script
Invoke-WebRequest -Uri "https://install.python-poetry.org" -OutFile $temp_installer_file

# run the installer script
Invoke-Expression "$python_exe $temp_installer_file --version $version_to_install"

# add poetry to path
$orig_path = [System.Environment]::GetEnvironmentVariable("PATH")
$new_path = $installed_path + [IO.Path]::DirectorySeparatorChar + "bin" + [IO.Path]::PathSeparator + $orig_path
[System.Environment]::SetEnvironmentVariable("PATH", $new_path)

$values = @{
    "POETRY_HOME" = $installed_path
    "PATH" = $new_path
}

# save it to the github environment variables
foreach ($var in $values.GetEnumerator()) {
    Write-Output "$($var.Name)=$($var.Value)" | Out-File -Encoding utf8 -Append -FilePath [System.Environment]::GetEnvironmentVariable("GITHUB_ENV")
}

poetry config virtualenvs.in-project false
poetry config virtualenvs.path .virtualenvs
