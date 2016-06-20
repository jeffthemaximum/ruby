# Users

- find by id
```
User.find(1)
```

- Find by other column
```
User.find_by(email: "mhartl@example.com")
```

- Pop first row
```
User.first
```

- Update multiple attributes
```
>> user.update_attributes(name: "The Dude", email: "dude@abides.org")
=> true
>> user.name
=> "The Dude"
>> user.email
=> "dude@abides.org"
```

- Update just one attribute
```
>> user.update_attribute(:name, "The Dude")
=> true
>> user.name
=> "The Dude"
```

# Grants

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
# or
g = Grant.where("data ->> 'link' = 'http://www.ssrc.org/fellowships/view/transregional-research-fellowship/'").last
```
- This gets the last Grant where the link of the grant is the one pasted above
- If no Grant is found, returns `nil`

#### All Grants by one organization
- Get all Grants by "Social Science Research Council"
```
Grant.where('data @> ?', {organization: "Social Science Research Council"}.to_json)
# or
Grant.where("data ->> 'organization' = 'Social Science Research Council'")
```

## Select only certain 'columns'

- Return just the links for all Grants
```
links = Grant.select("data -> 'link' as link")
links[0].link
# returns "https://www.gpo.gov/fdsys/pkg/FR-2016-03-08/pdf/2016-05155.pdf"
``` 

