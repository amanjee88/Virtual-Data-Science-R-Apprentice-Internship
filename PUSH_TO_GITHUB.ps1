$ErrorActionPreference = 'Stop'

Write-Host "`nGitHub publishing helper - Virtual Data Science with R Apprentice" -ForegroundColor Cyan
Write-Host "This script will add, commit, and push the current project folder."
Write-Host "It will not ask for or store a GitHub password or personal access token.`n"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Git was not found. Install Git for Windows from https://git-scm.com/download/win, reopen PowerShell, and run this script again."
}

$repoUrl = Read-Host "Paste the HTTPS URL of the EMPTY GitHub repository you just created"
if ($repoUrl -notmatch '^https://github\.com/[^/]+/[^/]+(?:\.git)?/?$') {
    throw "That URL does not look like a GitHub repository HTTPS URL. Example: https://github.com/your-username/Virtual-Data-Science-R-Apprentice-Internship.git"
}

if (-not (Test-Path (Join-Path (Get-Location) 'README.md'))) {
    throw "README.md was not found. Run this script from inside the extracted r_apprentice_project folder."
}

if (-not (Test-Path '.git')) {
    git init
    if ($LASTEXITCODE -ne 0) { throw "git init failed." }
}

if (-not (git config user.name)) {
    $gitName = Read-Host "Enter the name to record in your Git commits"
    if ([string]::IsNullOrWhiteSpace($gitName)) { throw "A Git commit name is required." }
    git config user.name $gitName
}
if (-not (git config user.email)) {
    $gitEmail = Read-Host "Enter the email to record in your Git commits"
    if ([string]::IsNullOrWhiteSpace($gitEmail)) { throw "A Git commit email is required." }
    git config user.email $gitEmail
}

git add .
if ($LASTEXITCODE -ne 0) { throw "git add failed." }

# Create a commit only when staged changes exist.
git diff --cached --quiet
if ($LASTEXITCODE -eq 1) {
    git commit -m "Add Virtual Data Science with R Apprentice project"
    if ($LASTEXITCODE -ne 0) { throw "git commit failed. Check the message above." }
} elseif ($LASTEXITCODE -gt 1) {
    throw "Unable to inspect staged changes."
} else {
    Write-Host "No new staged changes; continuing with the existing commit." -ForegroundColor Yellow
}

git branch -M main
if ($LASTEXITCODE -ne 0) { throw "Unable to set the branch name to main." }

$existingOrigin = git remote get-url origin 2>$null
if ($LASTEXITCODE -eq 0 -and $existingOrigin) {
    git remote set-url origin $repoUrl
} else {
    git remote add origin $repoUrl
}
if ($LASTEXITCODE -ne 0) { throw "Unable to configure the origin remote." }

Write-Host "`nPushing to GitHub. Git Credential Manager may open a browser for sign-in..." -ForegroundColor Cyan
git push -u origin main
if ($LASTEXITCODE -ne 0) {
    throw "Push did not complete. If GitHub reports that the remote contains work, create a new EMPTY repository (without README/license/gitignore) and rerun this script with its URL. Do not force-push."
}

Write-Host "`nSuccess. Your repository is now published at:" -ForegroundColor Green
Write-Host ($repoUrl -replace '\.git/?$', '') -ForegroundColor Green
