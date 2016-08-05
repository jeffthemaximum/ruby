We're trying to add file uploads to the site. Potentially projects, updates, and lab notes will have files uploaded to them.

From an engineering end, I'm making a plan for how we can do this.

It's important to me that the file uploads work in a similar way to how image uploads currently work on the site. I want file uploads to work similar to image uploads for a couple reasons..

I think it'd be confusing for developers if we have two different front-end and back-end strategies for uploading files
I think the current method for uploading images is really well done
With this in mind, I set out to get a handle on exactly how image uploads currently work, down to pretty nitty gritty details.

I wrote myself up some notes and left them here: https://github.com/jeffthemaximum/ruby/blob/master/full-stack/image_uploads.md
Hopefully these notes will serve as a helpful tutorial for others who want to get a handle on the engineering behind uploading images.