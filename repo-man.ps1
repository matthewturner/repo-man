$settings = Get-Content "settings.json" | ConvertFrom-Json

$owner_type = $settings.owner_type
$owner = $settings.owner
$search_term = $settings.search_term
$date_format = $settings.date_format
$duration = $settings.duration

$date_since = (Get-Date).AddDays(-$duration)

Write-Output "Searching for repos matching $search_term, pushed to since $($date_since.ToString($date_format)):"
Write-Output ""

$per_page = 100

$allRepos = @()
$page = 1
do {
    $search_path = "/search/repositories?page={0}&per_page={1}&q=in:name+{2}+{3}%3A{4}" `
        -f $page, $per_page, $search_term, $owner_type, $owner

    $search_results = $(gh api $search_path) | ConvertFrom-Json

    $repos = $search_results.Items

    $allRepos += $repos    
    $repoCount = $repos.Count

    $page += 1

} while ($repoCount -gt 0)

$recentRepos = @()
foreach ( $repo in $allRepos ) {
    if ($repo.pushed_at -gt $date_since) {
        $recentRepos += $repo
    }
}

Write-Output "The following repos have been pushed to:"
Write-Output ""

foreach ( $repo in $recentRepos ) {
    Write-Output "$($repo.name.PadRight(40)) $($repo.pushed_at.ToString($date_format))"
}

Write-Output ""