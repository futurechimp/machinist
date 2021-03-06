require File.dirname(__FILE__) + '/spec_helper'
require 'support/data_mapper_environment'

describe Machinist::DataMapper do
  include DataMapperEnvironment

  before(:each) do
    purge_models!
  end
  
  context "make" do
    it "should return an unsaved object" do
      Post.blueprint { }
      post = Post.make
      post.should be_a(Post)
      post.should be_new
    end
  end
  
  context "make!" do
    it "should make and save objects" do
      Post.blueprint { }
      post = Post.make!
      post.should be_a(Post)
      post.should_not be_new
    end

    it "should raise an exception for an invalid object" do
      User.blueprint { }
      lambda {
        User.make!(:username => "")
      }.should raise_error(DataMapper::SaveFailureError)
    end
  end
  
  context "associations support" do
    it "should handle belongs_to associations" do
      User.blueprint do
        username { "user_#{sn}" }
      end
      Post.blueprint do
        author
      end
      post = Post.make!
      post.should be_a(Post)
      post.should_not be_new
      post.author.should be_a(User)
      post.author.should_not be_new
    end
    
    it "should handle has_many associations" do
      Post.blueprint do
        comments(3)
      end
      Comment.blueprint { }
      post = Post.make!
      post.should be_a(Post)
      post.should_not be_new
      post.should have(3).comments
      post.comments.each do |comment|
        comment.should be_a(Comment)
        comment.should_not be_new
      end
    end
    
    it "should handle habtm associations" do
      Post.blueprint do
        tags(3)
      end
      Tag.blueprint do
        name { "tag_#{sn}" }
      end
      post = Post.make!
      post.should be_a(Post)
      post.should_not be_new
      post.should have(3).tags
      post.tags.each do |tag|
        tag.should be_a(Tag)
        tag.should_not be_new
      end
    end
    
    it "should handle overriding associations" do
      User.blueprint do
        username { "user_#{sn}" }
      end
      Post.blueprint do
        author { DataMapperEnvironment::User.make!(:username => "post_author_#{sn}") }
      end
      post = Post.make!
      post.should be_a(Post)
      post.should_not be_new
      post.author.should be_a(User)
      post.author.should_not be_new
      post.author.username.should =~ /^post_author_\d+$/
    end
  end
  
  context "error handling" do
    it "should raise an exception for an attribute with no value" do
      User.blueprint { username }
      lambda {
        User.make
      }.should raise_error(ArgumentError)
    end
  end
end
