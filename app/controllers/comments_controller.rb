class CommentsController < ApplicationController
  before_action :set_post, only: [:create, :index]
  before_action :set_comment, only: [:destroy]

  def index
    @comments = @post.comments.order(created_at: :desc).page(params[:page]).per(30)
  end

  def create
    # current_user can be nil
    @comment = @post.comments.create(comment_params.merge(user_id: current_user&.id))
    redirect_to post_path(@post)
  end

  def destroy
    @comment.destroy if @comment.can_delete_by?(current_user)
    redirect_back(fallback_location: root_path)
  end

  private

    def set_comment
      @comment = Comment.find_by_id params[:id]
    end

    def set_post
      @post = Post.find_by_slug(params[:post_id]) || Post.find_by_id(params[:post_id])
    end

    def comment_params
      params.require(:comment).permit(:content, :email, :name)
    end
end
