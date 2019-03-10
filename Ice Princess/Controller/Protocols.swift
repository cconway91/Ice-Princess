import AVFoundation

protocol EpisodesViewControllerDelegate: class {
    func updateCheckmark()
}

protocol PauseVideoDelegate: class {
    func pauseVideo()
}

protocol RecordingsTableViewCellDelegate: class {
    func shareVideo(senderCell: RecordingsTableViewCell, videoURL: URL, videoName: String)
    func deleteVideo(senderCell: RecordingsTableViewCell, videoURL: URL)
    func playVideoTapped(senderCell: RecordingsTableViewCell)
}

protocol SegueHandler: class {
    func segueToNext(identifier: String)
}

protocol ShareViewControllerDelegate: class {
    func verticalVideoSelected()
    func squareVideoSelected()
    func shareBtnAction()
}

extension RecordingsTableViewCellDelegate
{
    func playVideoTapped(senderCell: RecordingsTableViewCell)
    {}
}
