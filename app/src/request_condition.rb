class RequestCondition
  def self.check(event, event_id, last_event_id)
    conds = []
    conds << (Time.now.to_f - (event['ts']).to_f < 10.0)
    conds << (event['channel'] == ENV['CHANNEL'])
    conds << (event['user'] != ENV['BOT_SLACK_ID'])
    conds << (event_id != last_event_id)
    return conds.all?
  end
end
