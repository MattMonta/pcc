class Comment < ApplicationRecord
  has_many :sub_comments
  belongs_to :user
  belongs_to :category
  has_many :comment_sub_categories, dependent: :destroy
  has_many :sub_categories, through: :comment_sub_categories
  has_many :by_user_comment_upvotes


  scope :from_category, ->(category_name) { includes(:category).where(category: Category.where(name: category_name)) }
  scope :from_sub_categories, ->(sub_category_names) { includes(:sub_categories).where(sub_categories: { name: sub_category_names }) }

  # scope :debat, ->(debat_title) { includes(:comments).where(comments: { title: debat_title }) }

  scope :from_date, ->(date_from) { where("precise_date >= ?", date_from)}

  validates :title, presence: true
  validates :text, presence: true
  validates :category, presence: true
  validates :sub_categories, presence: true





  default_scope { order(upvotes: :desc) }
end
