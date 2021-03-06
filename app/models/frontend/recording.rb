module Frontend
  class Recording < ::Recording
    belongs_to :event, class_name: Frontend::Event
    scope :by_mime_type, ->(mime_type) { where(mime_type: mime_type) }
    scope :audio, -> { where(mime_type: MimeType::AUDIO) }

    def url
      File.join self.event.conference.recordings_url, self.folder || '', self.filename
    end

    def torrent_url
      url + '.torrent'
    end

    def display_mime_type
      MimeType.display_mime_type(mime_type)
    end

    def filetype
      MimeType.humanized_mime_type(mime_type)
    end
  end
end
