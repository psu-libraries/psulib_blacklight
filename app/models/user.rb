# frozen_string_literal: true

class User < ApplicationRecord
  # Connects this user object to Blacklight's Bookmarks.
  has_many :bookmarks, dependent: :destroy, as: :user

  def bookmarks_for_documents(documents = [])
    if documents.any?
      bookmarks.where(document_type: documents.first.class.base_class.to_s, document_id: documents.map(&:id))
    else
      []
    end
  end

  def document_is_bookmarked?(document)
    bookmarks_for_documents([document]).any?
  end

  # returns a Bookmark object if there is one for document_id, else
  # nil.
  def existing_bookmark_for(document)
    bookmarks_for_documents([document]).first
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :http_header_authenticatable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end
end
