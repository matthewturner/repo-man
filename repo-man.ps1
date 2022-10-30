$token = Get-Content token.txt
$per_page = 100
$base_url = "https://api.github.com/user"

$date_since = (Get-Date).AddDays(-80)

Write-Output $date_since

$pat = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($token))

$allRepos = @()
$page = 0
do {
    $page += 1    
    $params = @{'Uri' = ('{0}/repos?page={1}&per_page={2}' -f
            $base_url, $page, $per_page)
        'Headers'     = @{'Authorization' = 'Basic ' + $pat }      
        'Method'      = 'GET'                
        'ContentType' = 'application/json'
    }
    $repos = Invoke-RestMethod @params   
    $allRepos += $repos    
    $repoCount = $repos.Count 
} while ($repoCount -gt 0)

foreach ( $repo in $allRepos ) {
    if ($repo.pushed_at -gt $date_since) {
        Write-Output $repo
        Write-Output $repo.name
        Write-Output $repo.pushed_at
    }
}