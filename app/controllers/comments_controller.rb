class CommentsController < ApplicationController

  def index
    search = params[:query]
    if search
      if search[:date_from] && search[:category_name] && search[:sub_category_names] && search[:sub_category_names].reject(&:blank?).any?
        @comments = Comment.from_date(search[:date_from]) & Comment.from_sub_categories(search[:sub_category_names])
        # @articles = policy_scope(Article)
        @sub_categories_selected = SubCategory.where(name: search[:sub_category_names])
        @category = @sub_categories_selected.last&.category
        @sub_categories = @category&.sub_categories
      elsif search[:date_from] && search[:category_name]
        @comments = Comment.from_date(search[:date_from]) & Comment.from_category(search[:category_name])
        # @articles = policy_scope(Article)
        @category = Category.find_by_name(search[:category_name])
        @sub_categories = @category.sub_categories
      elsif search[:date_from]
        @comments = Comment.from_date(search[:date_from])
        # @articles = policy_scope(Article)
      end
    else
      @comments = Comment.all
      # @articles = policy_scope(Article)
      @sub_categories = []
      @category = Category.find_by_name("top")
    end
    @categories = Category.all
  end

  def new
    @user = current_user
    @comment = Comment.new
    authorize @comment
  end

  def create
    @comment = Comment.new(comment_params)
    authorize @comment
    @comment.user = current_user
    months = ["nil", "janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre" "décembre"]
    @comment.date = Time.now.to_s.split()[0].split("-")[2] + " " + months[Time.now.to_s.split()[0].split("-")[1].to_i] + " " + Time.now.to_s.split()[0].split("-")[0]
    @comment.precise_date = DateTime.now
    cat = @comment.sub_categories.map(&:category).first
    @comment.category = cat
    # article_comment = Article.create(URL: params[:comment][:source])
    # article_comment.category = cat
    # article_comment.user = current_user
    # article_comment.date = Time.now.to_s.split()[0].split("-")[2] + " " + months[Time.now.to_s.split()[0].split("-")[1].to_i] + " " + Time.now.to_s.split()[0].split("-")[0]
    # article_comment.precise_date = DateTime.now
    # html_file = open(article_comment.URL.strip).read
    # html_doc = Nokogiri::HTML(html_file)
    # article_comment.title = html_doc.css('html > head > title').text
    # article_comment.site_description = html_doc.xpath('/html/head/meta[@name="description"]/@content').to_s
    # head_image = html_doc.xpath('/html/head/meta[@property="og:image"]/@content').to_s
    # first_body_image = html_doc.search('img').first.attribute('src').value if !html_doc.search('img').first.attribute('src').nil?
    # image = head_image.empty? ? first_body_image : head_image
    # article_comment.image = image
    # article_comment.source = URI.parse(article_comment.URL.strip).host
    if @comment.save
      redirect_to comments_path(query: { category_name: @comment.category.name, date_from: -1.days.from_now })
    else
      render :new
    end
  end

  def show
    @categories = Category.all
    @comment = Comment.find(params[:id])
    authorize @comment
    @sub_comments = @comment.sub_comments
    @sub_comment = SubComment.new
    @answers = @sub_comment.answers
    @answer = Answer.new
  end


  def upvote
    @comment = Comment.find(params[:id])
    authorize @comment
    if @comment.by_user_comment_upvotes.any? {|by_user_comment_upvote| by_user_comment_upvote.user_id == current_user.id}
    else
      new_upvote = ByUserCommentUpvote.create(:user_id => current_user.id)
      new_upvote.comment = @comment
      new_upvote.save
      @comment.increment!(:upvotes)
      if @comment.save
        respond_to do |format|
          format.html { redirect_to request.referrer }
          format.js
        end
      end
    end
  end


  # def participants
  #   array = []
  #     @article.comments.each do |comment|
  #       array << comment.user.pseudo
  #     end
  #     new_array = array.uniq
  #     new_array.each do |element|
  #       element
  #     end
  # end

  private

  def comment_params
    params.require(:comment).permit(:title, :text, :source, :upvotes, :category_id, :date, sub_category_ids: [])
  end
end

