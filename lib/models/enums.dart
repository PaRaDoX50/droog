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

enum ConnectionStatus{
  requestSent,
  droogs,
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
enum QualityType{
  skill,
  achievement,
}