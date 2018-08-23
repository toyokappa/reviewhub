class ReviewRequestMailer < ApplicationMailer
  def open(review_req)
    review_vars(review_req)
    mail to: @reviewer.email, subject: "【BestCode】レビューリクエストがきました"
  end

  def change_request(review_req)
    review_vars(review_req)
    mail to: @reviewee.email, subject: "【BestCode】修正依頼がきました"
  end

  def rereview_request(review_req)
    review_vars(review_req)
    mail to: @reviewer.email, subject: "【BestCode】再レビュー依頼がきました"
  end

  def approved(review_req)
    review_vars(review_req)
    mail to: @reviewee.email, subject: "【BestCode】レビューリクエストが承認されました"
  end

  def resolved(review_req)
    review_vars(review_req)
    mail to: @reviewer.email, subject: "【BestCode】レビューリクエストが解決されました"
  end

  def closed(review_req)
    review_vars(review_req)
    mail to: @reviewer.email, subject: "【BestCode】レビューリクエストがクローズされました"
  end

  def reopen(review_req)
    review_vars(review_req)
    mail to: @reviewer.email, subject: "【BestCode】レビューリクエストが再開されました"
  end

  def commented(review_comment, review_req)
    @review_comment = review_comment
    @review_req = review_req
    reviewee = review_req.reviewee
    @commentee = (@review_comment.user == reviewee) ? @review_req.room.reviewer : reviewee
    mail to: @commentee.email, subject: "【BestCode】レビューリクエストにコメントが付きました"
  end

  private

    def review_vars(review_req)
      @review_req = review_req
      @reviewee = review_req.reviewee
      @reviewer = review_req.room.reviewer
    end
end
