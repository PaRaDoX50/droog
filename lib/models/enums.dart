enum LoggedInStatus{
  notLoggedIn,
  halfProfileLeft,
  loggedIn,

}
enum PictureFor{
  profilePicture,
  postPicture,
  messagePicture,

}

enum FollowStatus{
  requestSent,
  following,
  requestNotSent,
}

enum PostIs{
  normalPost,
  response,
  replyToAResponse,
}

enum VoteStatus{
  alreadyVoted,
  notVoted,
}

enum VoteType{
  upVote,
  undoUpVote,

}

enum UpdateType{
  responded,
  markedAsSolution,
  acceptedRequest,
}

enum MessageType{
  onlyText,
  image,
  sharedPost,
}