class RunFile < ActiveRecord::Base
  include RunFileWithMissedSplits

  has_many :runs, dependent: :restrict_with_exception, primary_key: :digest, foreign_key: :run_file_digest
  has_many :segments

  validates :digest, presence: true, uniqueness: true
  validates :file, presence: true
  validates_with RunFileValidator

  class << self
    def programs
      [LiveSplit, WSplit]
    end

    def for_file(file)
      RunFile.for_text(file.read)
    end

    def for_text(file_text)
      digest = Digest::SHA256.hexdigest(file_text)
      where(digest: digest).first_or_create!(file: file_text)
    end

    def random
      RunFile.offset(rand(RunFile.count)).first
    end
  end
end
