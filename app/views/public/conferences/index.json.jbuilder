json.cache! json_cached_key(:conferences, @conferences), expires_in: 10.minutes do
  json.conferences(@conferences) do |conference|
    json.partial! 'public/shared/conference', conference: conference
    json.url public_conference_url(conference, format: :json)
  end
end
