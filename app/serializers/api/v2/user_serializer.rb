class Api::V2::UserSerializer < ActiveModel::Serializer
  attributes :id, :twitch_id, :name, :avatar, :created_at, :updated_at
end