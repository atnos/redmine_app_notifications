class AppNotificationsController < ApplicationController
  unloadable
  # helper :app_notifications
  # include AppNotificationsHelper
  helper :custom_fields
  helper :issues

  def fetch_new_issue
    @app_notifications = AppNotification.where(recipient_id: User.current.id, viewed: false).where.not(issue_id: nil)
   apps = AppNotification.where(recipient_id: User.current.id, viewed: false).where('created_on >= ?', 5.seconds.ago)
   json = apps.map do |app|
     issue = app.issue
     id = app.id
     author= issue.author
     message_text  = if app.is_edited?
                       I18n.t(:text_issue_updated, :id => "##{issue.id}", :author => author)
                     else
                       I18n.t(:text_issue_added, :id => "##{issue.id}", :author => author)
                     end
     { count: @app_notifications.count, message: message_text, id: id, avatar: gravatar_url(author.mail, { :default => Setting.gravatar_default })}
   end
    render json: {datas: json}
  end

  def index
    @app_notifications = AppNotification.includes(:issue, :author, :journal, :news).where(recipient_id: User.current.id).order(created_on: :desc)
    if request.xhr?
      @app_notifications = @app_notifications.limit(5)
      render :partial => "ajax"
    end

    if !params.has_key?(:viewed) && !params.has_key?(:new) && !params.has_key?(:commit) 
      @viewed = false
      @new = true
    else
      params.has_key?(:viewed) ? @viewed = params['viewed'] : @viewed = false
      params.has_key?(:new) ? @new = params['new'] : @new = false
    end

    if(!@viewed && !@new)
      return @app_notifications = []
    end
    if(@viewed != @new)
      @app_notifications = @app_notifications.where(viewed: true) if @viewed
      @app_notifications = @app_notifications.where(viewed: false) if @new
    end
    @limit = 10
    @app_notifications_count = @app_notifications.to_a.length
    @app_notifications_pages = Redmine::VERSION::MAJOR > 3 ? (Paginator.new @app_notifications.to_a.length, @limit, params['page']) : (Paginator.new @app_notifications.count(:id).length, @limit, params['page'])
    @offset ||= @app_notifications_pages.offset
    @app_notifications = @app_notifications.limit(@limit).offset(@offset)
  end

  def view
    @notification = AppNotification.find(params[:id])

    if @notification.recipient == User.current 
      if params[:mark_as_unseen]
        AppNotification.update(@notification, :viewed => false)
      else
        @notices = AppNotification.where(recipient_id: @notification.recipient.id, viewed: false)
        if params[:issue_id]
          @notices = @notices.where(issue_id: @notification.issue.id).all
        elsif params[:news_id]
          @notices = @notices.where(news_id: @notification.news.id).all
        else
          @notices = nil
        end
        if @notices
          @notices.update_all(:viewed => true)
        end
      end

      if request.xhr?
        if @notification.is_edited?
          render :partial => 'issues/issue_edit', :formats => [:html], :locals => { :notification => @notification, :journal => @notification.journal }
        else
          render :partial => 'issues/issue_add', :formats => [:html], :locals => { :notification => @notification }
        end
      else
        if params[:issue_id]
          redirect_to :controller => 'issues', :action => 'show', :id => params[:issue_id], :anchor => params[:anchor]
        elsif params[:news_id]
          redirect_to :controller => 'news', :action => 'show', :id => params[:news_id], :anchor => params[:anchor]
        end
      end
    end
  end

  def view_all
    AppNotification.where(:recipient_id => User.current.id, :viewed => false).update_all( :viewed => true )
    redirect_to :action => 'index'
  end

  def unread_number
    @number = AppNotification.where(recipient_id: User.current.id, viewed: false).count
    render :json => @number
  end

end
