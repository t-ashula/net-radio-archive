class Job < ActiveRecord::Base
  CH = {
    ag: 'ag',
  }
  STATE = {
    scheduled: 'scheduled',
    recording: 'recording',
    converting: 'converting',
    done: 'done',
    failed: 'failed',
  }

  def length_sec
    (self.end - self.start).to_i
  end

  def schedule
    # only update after 10 minutes form now
    if (self.start - Time.now).to_i < 10 * 60
      return
    end

    adapter = ActiveRecord::Base.connection_config[:adapter].downcase
    lock_clause = adapter == 'mysql2' ? 'LOCK IN SHARE MODE' : 'FOR SHARE'
    
    ActiveRecord::Base.transaction do
      exsist_job = Job
        .lock(lock_clause)
        .find_by(
          ch: self.ch,
          start: self.start
        )
      if exsist_job
        return exsist_job.update_attributes(
          ch: self.ch,
          title: self.title,
          start: self.start,
          end: self.end
        )
      end
      self.state = Job::STATE[:scheduled]
      self.save!
    end
  end
end
