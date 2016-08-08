# Current Issues

1 - Need to sanatize params in `app/controllers/file_attachment_controller.rb`
2 - Need to create a `def destroy` controller in `app/controllers/file_attachment_controller.rb`
3 - Need to display the uploaded file attachments somehow on the frontend in `views/updates/new.html.erb` after a user has uploaded an attachment
4 - Need to display the uploaded file attachments somehow on the frontend in the template rendered by `def share` in `updates_controller.rb`
5 - Display button to delete file attachment on `views/updates/new.html.erb`
6 - Display button to delete file attachment in the template rendered by `def edit` in `updates_controller.rb`
7 - break out the code in `def create` in `app/controllers/updates` that iterates over the file_attachment_ids into it's own method so it's not cluttering the controller
8 - Add validators to all models in `app/models/files/...`
9 - Put `has_many :file_attachments` associations in `User` and `Project` models
10 - Document how to add a `Add Upload` button to other pages, ideally like an upload API
11 - Add other file types, `PDF` and `CSV`
12 - Add file upload functionality to `project` pages, not just updates

# FAQ's

### Why 2 AJAX calls in `app/assets/javascripts/file_attachments/file_attachments.js`?

- There's one call to `/upload` and another to `/file_attachment/create`
- One reason is that there was already a `def create` controller in `app/controllers/uploads_controller` and already a `Upload` model in `app/models/upload.rb` and I wanted to reuse as much of this code as possible
- Another reason is that we create two different models, and `Upload` model and a `FileAttachment` model. It makes sense to have two difference endpoints for these two different pieces of logic
- A third reason is extensibility. We don't want to tie the creation of `FileAttachment`s to `Upload`s, because it lets us more flexibly create other subclasses of `FileAttachent`s in the future.

### Why store the file_attachment ID's in a hidden field in the form in `app/views/updates/_update_fields.html.erb`

- They get stored here in this HTML element:
```
<%= f.hidden_field :file_attachment_ids, value: '[]' %>
```
- By the `createFileAttachment` function in `app/assets/javascripts/file_attachments/file_attachments`
- It's a sorta complicated reason why.
- When the user uploads a file attachment in `views/updates/new.html.erb`, the `Update` object hasn't been created or saved to the DB yet.
- The `FileAttachment` model that's created at this point should have an associated `target` field, which would contain the `target_id`, in this case, the ID of the `Update` that the FileAttachment is associated with.
- We can't store that `update.id` with the `file_attachment.target_id` field yet because that `update` hasn't been created or saved.
- So the `createFileAttachment` created the `FileAttachment` model but doesn't save anything in the `target_id` or `target_type` columns, yet.
- We store all the Id's in the `<%= f.hidden_field :file_attachment_ids, value: '[]' %>` HTML field.
- Then, when the user submits the form in `views/updates/new.html.erb`, we send along all the file_attachment ID's.
- In the controller called by that form, `def create` in `app/controllers/updates` we run these codes to associate all the file_attachments with the update:

```
  file_attachment_ids = JSON.parse(params[:update][:file_attachment_ids])
  if file_attachment_ids.any?
    file_attachment_ids.each do |fa_id|

      # find file attachment by id
      fa = FileAttachment.find(fa_id)

      # set target of that file attachment to this update
      fa.target = @update

      # save file attachment
      fa.save

    end
  end
```

