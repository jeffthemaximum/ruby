## Last Grant
```
g = Grant.last
```

## Get whole Grant json
```
g.data
```

## Get Grant Where...

#### link == "http://www.ssrc.org/fellowships/view/transregional-research-fellowship/"
```
g = Grant.where('data @> ?', {link: "http://www.ssrc.org/fellowships/view/transregional-research-fellowship/"}.to_json).last
```
- This gets the last Grant where the link of the grant is the one pasted above
- If no Grant is found, returns `nil`

#### All Grants by one organization
- Get all Grants by "Social Science Research Council"
```
Grant.where('data @> ?', {organization: "Social Science Research Council"}.to_json)
```

