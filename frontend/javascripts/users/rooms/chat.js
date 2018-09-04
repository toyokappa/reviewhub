import moment from 'moment'
import Firebase from '../../lib/firebase'
import Message from '../../lib/message'

export default class Chat {
  constructor(gon) {
    const firebase = new Firebase();
    firebase.auth(gon.auth_token);
    this.firebase = firebase;
    this.message = new Message();
    this.roomId = gon.room_chat_id;
    this.currentUser = gon.current_user;
    this.usersInfo = gon.users_info;
    this.bind();
  }

  appendMessage(msgData) {
    var profilePath;
    var userImg;
    if(msgData.user_id === this.usersInfo.reviewer.id) {
      profilePath = this.usersInfo.reviewer.profile_path;
      userImg = this.usersInfo.reviewer.image;
    } else {
      profilePath = this.usersInfo.reviewee.profile_path;
      userImg = this.usersInfo.reviewee.image;
    }

    const msgSide = (msgData.user_id === this.currentUser.id) ? 'alt' : 'null';
    let msgElm = this.message.generateMessage(msgData, profilePath, userImg, msgSide);
    $('.chat-list').append(msgElm);
  }

  async sendMessage() {
    const $msgField = $('#message-field');
    const msgBody = $msgField.val();
    if(!msgBody) return;

    const regex = new RegExp(`https://github.com/${this.currentUser.name}/[\\w\\d]+/pull/\\d+`);
    var msgType = 'text';

    if(this.currentUser.id === this.usersInfo.reviewee.id && msgBody.match(regex)) {
    msgType = 'review_req';
    const path = `/users/rooms/${this.roomId.replace(/room_(\d+)_reviewee_\d+/, '$1')}/review_requests`;
      const pullUrl = msgBody.match(regex)[0];
      const authenticityToken = $('meta[name="csrf_token"]').attr('content');
      const params = { 
        url: pullUrl,
        reviewee_id: this.currentUser.id.replace('user_', ''),
        authenticity_token: authenticityToken
      };
      const response = await $.post(path, params);

      var checkSend
      switch(response.status) {
        case 'NO_PULLS':
          checkSend = confirm('PRが存在しないため、通常のテキストメッセージとして送信されますがよろしいですか？');
          if(!checkSend) return $msgField.val('');

          msgType = 'text';
          break;
        case 'EXIST_REVIEW_REQ':
          checkSend = confirm('すでにレビュー依頼中です。再依頼しますか？');
          if(!checkSend) return $msgField.val('');

          break;
      }
    }

    this.firebase.sendMessage(this.roomId, msgBody, msgType, this.currentUser.id);
    $msgField.val('');
  }

  bind() {
    $('#message-btn').on('click', (e) => {
      e.preventDefault();
      this.sendMessage();
    });

    this.firebase.onChangeMessages(this.roomId, (msgData) => {
      this.appendMessage(msgData);
    });
  }
}
