//
//  EpisodeCell.swift
//  LacunaPodcasts
//
//  Created by Priscilla Ip on 2020-06-30.
//  Copyright © 2020 Priscilla Ip. All rights reserved.
//

import UIKit

protocol EpisodeCellDelegate {
    func didTapCancel(_ cell: EpisodeCell)
}

class EpisodeCell: UITableViewCell {
    
    static var reuseIdentifier: String { String(describing: self) }
    static var nib: UINib { return UINib(nibName: String(describing: self), bundle: nil) }
    
    // MARK: - Variables and Properties
    
    var delegate: EpisodeCellDelegate?
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var downloadStatusView: UIView!
    @IBOutlet weak var downloadStatusButton: UIButton! {
        didSet {
            downloadStatusButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
            downloadStatusButton.addSubview(circularProgressBar)
            circularProgressBar.center(in: downloadStatusButton, xAnchor: true, yAnchor: true)
        }
    }
    
    let circularProgressBar: CircularProgressBar = {
        let bar = CircularProgressBar()
        return bar
    }()
    
    @objc private func handleTap() {
        delegate?.didTapCancel(self)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        downloadStatusView.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectedBackgroundView?.isHidden = true
        containerView.backgroundColor = isSelected ? UIColor(named: K.Colors.darkBlue) : UIColor(named: K.Colors.midnight)
        downloadStatusView.backgroundColor = isSelected ? UIColor(named: K.Colors.darkBlue) : UIColor(named: K.Colors.midnight)
    }
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }()
    
    var episode: Episode! {
        didSet {
            guard let url = URL(string: episode.imageUrl ?? "") else { return }
            episodeImageView.sd_setImage(with: url)
            titleLabel.text = episode.title
            descriptionLabel.text = episode.description.stripOutHtml()
            
            let pubDate = dateFormatter.string(from: episode.pubDate).uppercased()
            let duration = episode.duration.toDisplayString()
            detailsLabel.text = "\(pubDate) • \(duration)"
            
            
            
            titleLabel.textColor = episode.downloadStatus.titleColor
            descriptionLabel.textColor = episode.downloadStatus.descriptionColor
            detailsLabel.textColor = episode.downloadStatus.detailsColor
            
            // Non-nil Download object means a download is in progress
            if let download = APIService.shared.activeDownloads[episode.streamUrl] {
                print(download.episode.title)
            }
        }
    }
    
    
    
    
    
    
    func updateDisplay(progress: Double) {
        downloadStatusView.isHidden = false
        circularProgressBar.setProgress(to: progress)
        detailsLabel.text = "Downloading... \(Int(progress * 100))%"
    }
    
    func updateDisplayForDownloadPending() {
        detailsLabel.textColor = UIColor(named: K.Colors.orange)
        detailsLabel.text = "Waiting for download..."
    }
    
}
