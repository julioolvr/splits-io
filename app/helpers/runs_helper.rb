module RunsHelper
  include ActionView::Helpers::DateHelper

  TIMELINE_COLORS = [:blue, :purple, :green, :yellow, :red, :orange]

  def difference(run_a, run_b)
    if run_a.nil? || run_b.nil?
      return 0
    end

    run_a.duration_ms(Run::REAL) - run_b.duration_ms(Run::REAL)
  end

  def sob_difference(run_a, run_b)
    if run_a.nil? || run_b.nil?
      return 0
    end

    run_a.sum_of_best_ms(Run::REAL) - run_b.sum_of_best_ms(Run::REAL)
  end

  def difference_color(time)
    if time == 0
      'text-primary'
    elsif time > 0
      'text-danger'
    else
      'text-success'
    end
  end

  def table_locals(table_type, options = {})
    case table_type
    when :my_pbs
      {
        type: :current_user,
        source: current_user,
        runs: current_user.pbs,
        cols: [:time, :name, :uploaded, :owner_controls, :rival],
        description: "My Personal Bests"
      }.merge(sorting_info)
    when :pbs
      {
        type: :user,
        source: options[:user],
        runs: options[:user].pbs,
        cols: [:time, :name, :uploaded],
        description: "Personal Bests"
      }.merge(sorting_info)
    when :games
      {
        type: :games,
        source: options[:games],
        runs: Run.by_game(options[:games]).nonempty,
        cols: [:runner, :time, :name, :uploaded]
      }.merge(sorting_info)
    when :category
      {
        type: :category,
        source: options[:category],
        runs: options[:category].runs.nonempty,
        cols: [:runner, :time, :name, :uploaded]
      }.merge(sorting_info)
    else
      raise Error
    end
  end

  def next_timeline_color(timeline_id)
    if @next_index.blank?
      @next_index = {}
    end

    if @next_index[timeline_id].blank?
      @next_index[timeline_id] = 0
    else
      @next_index[timeline_id] = (@next_index[timeline_id] + 1) % TIMELINE_COLORS.length
    end

    TIMELINE_COLORS[@next_index[timeline_id]]
  end

  def pretty_timestamp(timestamp)
    "<span title=\"#{timestamp}\">#{time_ago_in_words(timestamp)} ago</span>".html_safe
  end

  def pretty_duration(seconds)
    ms = (seconds * 1000).floor

    return "<span class=\"text-default\">#{format_milliseconds(ms)}</span>".html_safe
  end

  def pretty_difference(my_ms, their_ms)
    diff_s = (my_ms / 1000) - (their_ms / 1000)

    if diff_s < 0
      diff_s = diff_s.abs
      return "<span class=\"text-success\">-#{format_milliseconds(diff_s * 1000)}</span>".html_safe
    end

    if diff_s > 0
      return "<span class=\"text-danger\">+#{format_milliseconds(diff_s * 1000)}</span>".html_safe
    end

    return "<span class=\"text-warning\">+#{format_milliseconds(diff_s * 1000)}</span>".html_safe
  end

  def format_milliseconds(milliseconds)
    if milliseconds.nil?
      return '-'
    end

    total_seconds = milliseconds / 1000
    total_minutes = total_seconds / 60
    total_hours   = total_minutes / 60

    seconds = total_seconds % 60
    minutes = total_minutes % 60
    hours   = total_hours

    "%02d:%02d:%02d" % [hours, minutes, seconds]
  end

  private

  def sorting_info
    {
      page: params[:page] || 1,
      order: [
        params[:by],
        params[:order]
      ]
    }
  end
end
