# Controllers

- Here’s a typical usage of before_filter:
```
class Admin::ArticlesController < ApplicationController
  before_filter :deny_access, :unless => :draft_and_admin?

  def show
    @article = Article.find(params[:id])
  end

  protected

  def draft_and_admin?
    Article.find(params[:id]).draft? && current_user.admin?
  end
end
```
- Awesome. We deny the user access to the show action if the article is a draft and they are not an admin. The show action looks standard. When we look at the top of the file, we see a nice one-liner encapsulating concerns of authorization.