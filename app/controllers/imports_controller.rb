require "fileutils"

class ImportsController < ApplicationController
  def new
    @summary = import_summary
  end

  def create
    uploaded_file = params.dig(:import, :file)

    if uploaded_file.blank?
      assign_flash(:alert, "インポートするファイルを選択してください。")
      return respond_with_summary(status: :unprocessable_content)
    end

    save_uploaded_file!(uploaded_file)
    result = Imports::StoriesXlsxImporter.new(import_file_path).call

    assign_flash(:notice, "インポートが完了しました (エピック #{result.epics_count} 件 / ストーリー #{result.stories_count} 件)")
    respond_with_summary
  rescue StandardError => e
    Rails.logger.error("Import failed: #{e.class} - #{e.message}\n#{e.backtrace.take(10).join("\n")}")
    assign_flash(:alert, "インポートに失敗しました: #{e.message}")
    respond_with_summary(status: :internal_server_error)
  end

  def destroy
    delete_all_records!
    FileUtils.rm_f(import_file_path)
    assign_flash(:notice, "ストーリーと関連データを削除しました。")
    respond_with_summary
  end

  private

  def respond_with_summary(status: :see_other)
    @summary = import_summary

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("flash", partial: "shared/flash"),
          turbo_stream.replace("import_summary", partial: "imports/summary", locals: { summary: @summary })
        ], status: status
      end
      format.html { redirect_to new_import_path }
    end
  end

  def assign_flash(type, message)
    if request.format.turbo_stream?
      flash.now[type] = message
    else
      flash[type] = message
    end
  end

  def save_uploaded_file!(uploaded_file)
    File.open(import_file_path, "wb") do |file|
      uploaded_file.rewind
      IO.copy_stream(uploaded_file, file)
    end
  end

  def import_file_path
    Rails.root.join("stories.xlsx")
  end

  def import_summary
    {
      stories_count: Story.count,
      epics_count: Epic.count,
      labels_count: StoryLabel.distinct.count(:name),
      last_imported_at: Story.maximum(:updated_at),
      file_present: File.exist?(import_file_path),
      file_updated_at: File.exist?(import_file_path) ? File.mtime(import_file_path) : nil
    }
  end

  def delete_all_records!
    ActiveRecord::Base.transaction do
      StoryBranch.delete_all
      StoryPullRequest.delete_all
      StoryBlocker.delete_all
      StoryTask.delete_all
      StoryComment.delete_all
      StoryOwnership.delete_all
      StoryLabel.delete_all
      Story.delete_all
      Epic.delete_all
    end
  end
end
