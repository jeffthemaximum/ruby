- **Last updated:** August 8, 2016

- This is my attempt to document the model and table structure for `FileAttachment`s

# Resources
- https://samurails.com/tutorial/single-table-inheritance-with-rails-4-part-1/
- http://www.informit.com/articles/article.aspx?p=2220311&seqNum=
- http://railscasts.com/episodes/394-sti-and-polymorphic-associations?view=asciicast

# STI

- I used Single Table Inheritance (STI) as a foundation for the `FileAttachment` model.
- From https://samurails.com/tutorial/single-table-inheritance-with-rails-4-part-1/ ... "STI lets you save different models inheriting from the same model inside a single table."
- I chose this structure because I wanted the `FileAttachment` model to contain common structure and logic, and then other models, such as `ImageAttachment` to contain anything that was different about this specific subclass of attachments.

# `FileAttachent`

- This is the parent model
- It has a table in the DB created with `20160805175253_create_file_attachments.rb` that looks like this:

```
create_table "file_attachments", force: :cascade do |t|
    t.string   "type"
    t.integer  "user_id"
    t.integer  "project_id"
    t.integer  "upload_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "target_id"
    t.string   "target_type"
end
```

- The `type` column here is what stores the subclass of model, such as `ImageAttachment`
- There's references to the associated `user`, `project`, `upload`, and `target` associated objects
- Right now, `app/models/files/file_attachments.rb` looks like this:

```
class FileAttachment < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :upload

  belongs_to :target, polymorphic: true
end
```

# The `target` Polymorphic relationship

- The idea here is that a `FileAttachment` can belong to any number of things. So far, I've only connected them to `Update`s.
- To connect them to `Update`s ...
- I add this line to `app/models/update.rb`:

```
has_many :file_attachments, as: :target
```

- And I add this line to `app/models/files/file_attachment.rb`:

```
belongs_to :target, polymorphic: true
```

- This is enough for this functionality

```
fa = FileAttachment.last
fa.target
```


# ImageAttachment

- This is a subclass of `FileAttachment`
- There's no table in the DB for this
- I just created a file in `app/models/files/` called `image_attachments.rb` that looks like this:

```
class ImageAttachment < FileAttachment
end
```

- Right now, that's all it has.

# Creating ImageAttachment objects

- something like this

```
ia = ImageAttachment.new
ia.user = User.last
ia.target = Update.last
ia.project = Project.last
# ideally this would be the associated upload, just did last for demo purposes
ia.upload = Upload.last 
ia.save

=> #<ImageAttachment:0x007fa342e57df0
 id: 19,
 type: "ImageAttachment",
 user_id: 50427,
 project_id: 7246,
 upload_id: 39064,
 created_at: Mon, 08 Aug 2016 14:17:37 PDT -07:00,
 updated_at: Mon, 08 Aug 2016 14:17:42 PDT -07:00,
 target_id: 5676,
 target_type: "Update">
```

- Notice how rails is cool and fills in `type: "ImageAttachment"`, ` target_id: 5676` and `target_type: "Update"` for you.

# Querying FileAttachments

- You do something like this:

```
u = Update.last
u.file_attachments
>>> [#<ImageAttachment:0x007fa34c407210..., #<ImageAttachment:0x007fa34c406fb8...]
```

- or

```
ia = ImageAttachment.last
ia.user
=> #<User:0x007fa34e98a488
ia.project
=> #<Project:0x007fa34e9eaa18
ia.target
=> #<Update:0x007fa344c460f0
```
