# create file_attachment model
- This took me a couple tries to figure out, and I bricked it by making/closing PR's #6922 and # 6972
- I did this
```
rails g model file_attachment type:string user:references project:references upload:references
rake db:migrate
```

# tree structure
- I put `file_attachment.rb` into `app/models/files/` . 
- To load the models automatically with rails, I had to add the following to `application.rb`:

```
config.autoload_paths += %W(
  #{config.root}/app/lib
  #{config.root}/app/mailers/concerns
  #{config.root}/app/middleware
  #{config.root}/app/models/concerns
  #{config.root}/app/models/files
  #{config.root}/app/models/proactions
  #{config.root}/app/validators
  #{config.root}/app/workers/concerns
  #{config.root}/lib
)
```
- Where `#{config.root}/app/models/files` is the new line.

# PDF files
- in `app/models/files/` I made `pdf.rb`, which contained these codez:

```
class Pdf < FileAttachment
end
```

- That's enough to setup objects of type `Pdf` to inherit from the `FileAttachment` parent class.


# rails c

- To query a `FileAttachment`, you can do
```
fs = FileAttachment.all
f = FileAttachment.first
```

- To create a `Pdf` you can do:
```
p = Pdf.new
p.save
```

- To query for FileAttachments that are Pdf's, you can do
```
pdfs = FileAttachment.where(type:'Pdf')
```
- or
```
pdfs = Pdf.all
```


# Resources
- https://samurails.com/tutorial/single-table-inheritance-with-rails-4-part-1/
- http://www.informit.com/articles/article.aspx?p=2220311&seqNum=
- http://railscasts.com/episodes/394-sti-and-polymorphic-associations?view=asciicast