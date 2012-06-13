require 'test_helper'
class BasicUsage < ActiveSupport::TestCase
  context "Main API" do
    setup do
      @extract_code = 'Post.includes(:comments, :author).limit(1)'
      @extract_name = :first_post_w_comments_and_authors
    end
    context ".extract" do
      setup do
        FeTestEnv.setup
      end
      teardown do
        FeTestEnv.teardown
      end
      should "provide the right output, and put the file in the right place" do
        extract_hash = Fe.extract(@extract_code, :name => @extract_name)
        assert (%w(Post Comment Author) - extract_hash.keys).empty?, "only these keys should exist"
        assert_equal 'posts', extract_hash['Post']['table_name']
        assert_equal 1, extract_hash['Post']['row_count']
        assert File.exists?(File.join(Fe.fixtures_root,'first_post_w_comments_and_authors','posts.yml')), "The file is created"
        assert File.exists?(File.join(Fe.fixtures_root,'first_post_w_comments_and_authors','fe_manifest.yml')), "The file that allows the fixtures to get rebuilt"
      end
    end
    context ".load_db" do
      setup do
        FeTestEnv.setup # regular production db
        extract_hash = Fe.extract(@extract_code, :name => @extract_name)
        FeTestEnv.the_env = 'fake_test'
        FeTestEnv.recreate_schema_without_data
      end
      teardown do
        FeTestEnv.teardown
      end
      should "provide the ability to load fixtures" do
        assert_equal 0, Post.count
        assert_equal 0, Comment.count
        assert_equal 0, Author.count
        Fe.load_db(@extract_name)
        assert_equal 1, Post.count
        assert_equal 1, Comment.count
        assert_equal 1, Author.count
      end
    end
    context ".rebuild" do
      should "be able to rebuild the fixture files from the manifest" do
        FeTestEnv.destroy_tmp_test_stuff
        rebuild_hash = Fe.rebuild(@extract_name)
        #assert_equal 0, Post.count
      end
    end
  end
  # NOT SURE IF THESE MATTER, probably do..commented out for now
  #context "2nd tier API" do
    #should "provide an extractor class" do
      #extract_code = Post.first
      #e=Fe::Extractor.new
      #e.input_array = [extract_code]
      #assert_kind_of Hash, e.output_hash
      #assert_equal Post, e.output_hash.keys.first
      #assert_equal extract_code, e.output_hash[Post].first
    #end
    #should "work with recursive loading" do
      #e=Fe::Extractor.new
      #e.input_array = Post.includes(:comments, :author)
      #assert (e.output_hash.keys - [Post,Comment,Author]).empty?, "There are only keys for the eager loaded models"
    #end
  #end
end
