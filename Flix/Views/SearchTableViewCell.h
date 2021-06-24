//
//  SearchTableViewCell.h
//  Flix
//
//  Created by Harleen Kaur on 6/24/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *movieImage;
@property (weak, nonatomic) IBOutlet UILabel *movieTitle;

@end

NS_ASSUME_NONNULL_END
