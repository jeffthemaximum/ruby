### add a `deleted_at` datetime column to model

bundle exec rails g migration AddDeletedAtToFileAttachment deleted_at:datetime

### make default scope only find non deleted_at objects

default_scope { where( deleted_at: nil ) }

### add method to model.rb 

def delete_now
    touch(:deleted_at)
end

http://apidock.com/rails/ActiveRecord/Timestamp/touch

### make this the `destroy` controller

def destroy
    @file_attachment = FileAttachment.find(params[:id])
    @file_attachment.delete_now
    render json: { success: "success", status_code: "200" }
    # TODO redirect? json?
end