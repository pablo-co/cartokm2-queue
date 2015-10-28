class Base

  ENVIRONMENT = 'development'

  def self.root
    Dir.pwd
  end

  def self.env
    ENV['JOBS_ENVIRONMENT'] || ENVIRONMENT
  end

end