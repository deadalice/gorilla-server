module Blockips
  class Middleware

    RESTRICTED_PATHS = %w[
      /console
      /wp-admin
      /api
      /admin
    ]

    RESTRICTED_PATHS_STARTS = %w[
      /Autodiscover/
      /wp-content/
      /index.php
      /vendor/
      /solr/admin/
      /?XDEBUG_SESSION_START
      /.
    ]

    def initialize(app)
      @app = app
    end

    def call(env)
      if valid?(env)
        @app.call(env)
      else
        Rails.logger.warn "\u{21B3} Blocked #{@uri} for #{@ip}"
        [444, {}, []]
      end
    end

    private

    def valid?(env)
      @uri = env['REQUEST_URI']
      @path = env['REQUEST_PATH']
      @ip = env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_ADDR']
      valid_path && valid_path_starts
    end

    def valid_path
      !RESTRICTED_PATHS.include? @path
    end

    def valid_path_starts
      RESTRICTED_PATHS_STARTS.none? { |s| @uri.starts_with?(s) }
    end

    # TODO: Update IP black list for nginx and reload
  end
end