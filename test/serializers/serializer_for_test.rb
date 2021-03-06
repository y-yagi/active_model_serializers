require 'test_helper'

module ActiveModel
  class Serializer
    class SerializerForTest < Minitest::Test
      class CollectionSerializerTest < Minitest::Test
        def setup
          @array = [1, 2, 3]
          @previous_collection_serializer = ActiveModel::Serializer.config.collection_serializer
        end

        def teardown
          ActiveModel::Serializer.config.collection_serializer = @previous_collection_serializer
        end

        def test_serializer_for_array
          serializer = ActiveModel::Serializer.serializer_for(@array)
          assert_equal ActiveModel::Serializer.config.collection_serializer, serializer
        end

        def test_overwritten_serializer_for_array
          new_collection_serializer = Class.new
          ActiveModel::Serializer.config.collection_serializer = new_collection_serializer
          serializer = ActiveModel::Serializer.serializer_for(@array)
          assert_equal new_collection_serializer, serializer
        end
      end

      class SerializerTest < Minitest::Test
        module ResourceNamespace
          Post    = Class.new(::Model)
          Comment = Class.new(::Model)

          class PostSerializer < ActiveModel::Serializer
            class CommentSerializer < ActiveModel::Serializer
            end
          end
        end

        class MyProfile < Profile
        end

        class CustomProfile
          def serializer_class; ProfileSerializer; end
        end

        Tweet = Class.new(::Model)
        TweetSerializer = Class.new

        def setup
          @profile = Profile.new
          @my_profile = MyProfile.new
          @custom_profile = CustomProfile.new
          @model = ::Model.new
          @tweet = Tweet.new
        end

        def test_serializer_for_non_ams_serializer
          serializer = ActiveModel::Serializer.serializer_for(@tweet)
          assert_nil(serializer)
        end

        def test_serializer_for_existing_serializer
          serializer = ActiveModel::Serializer.serializer_for(@profile)
          assert_equal ProfileSerializer, serializer
        end

        def test_serializer_for_not_existing_serializer
          serializer = ActiveModel::Serializer.serializer_for(@model)
          assert_equal nil, serializer
        end

        def test_serializer_inherited_serializer
          serializer = ActiveModel::Serializer.serializer_for(@my_profile)
          assert_equal ProfileSerializer, serializer
        end

        def test_serializer_custom_serializer
          serializer = ActiveModel::Serializer.serializer_for(@custom_profile)
          assert_equal ProfileSerializer, serializer
        end

        def test_serializer_for_namespaced_resource
          post = ResourceNamespace::Post.new
          serializer = ActiveModel::Serializer.serializer_for(post)
          assert_equal(ResourceNamespace::PostSerializer, serializer)
        end

        def test_serializer_for_nested_resource
          comment = ResourceNamespace::Comment.new
          serializer = ResourceNamespace::PostSerializer.serializer_for(comment)
          assert_equal(ResourceNamespace::PostSerializer::CommentSerializer, serializer)
        end
      end
    end
  end
end
