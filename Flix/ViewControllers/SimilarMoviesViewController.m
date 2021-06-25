//
//  SimilarMoviesViewController.m
//  Flix
//
//  Created by Harleen Kaur on 6/25/21.
//

#import "SimilarMoviesViewController.h"
#import "MovieCollectionCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface SimilarMoviesViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *similarMovies;
@property (nonatomic,strong) UIRefreshControl *refreshControl;
@end

@implementation SimilarMoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self fetchMovies];
    
    //Refresh Control
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = UIColor.whiteColor;
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.collectionView insertSubview:self.refreshControl atIndex:0];
    
    //Layout
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    
    CGFloat postersPerLine = 2;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.sectionInset.left - layout.sectionInset.right - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    layout.itemSize = CGSizeMake( itemWidth, (itemWidth - layout.sectionInset.top)*1.5);
    
}

- (void) fetchMovies {
    // Getting the API
    NSString *movie_id = [NSString stringWithFormat:@"%@", self.movie[@"id"]];
    NSString *startURLString = @"https://api.themoviedb.org/3/movie/";
    NSString *endURLString = @"/similar?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed";
    NSString *completeURLString = [[startURLString stringByAppendingString: movie_id] stringByAppendingString:endURLString];
    NSURL *url =[NSURL URLWithString:completeURLString];
    NSLog(@"%@", completeURLString);
//    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie//now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
               //Creating the Alert
               UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Movies"
                                                                                          message:@"The internet connection appears to be offline"
                                                                                   preferredStyle:(UIAlertControllerStyleAlert)];
               
               // create an try again action
               UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
                                                                        // handle response here.
                                                                        [self fetchMovies];
                                                                }];
               // add the try again action to the alert controller
               [alert addAction:tryAgainAction];
               
               [self presentViewController:alert animated:YES completion:^{
                   // optional code for what happens after the alert controller has finished presenting
               }];
           }
           else {
                   NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

                   // TODO: Get the array of movies
                   self.similarMovies = dataDictionary[@"results"];
               
                    //if no similar movies found
               if (self.similarMovies.count == 0){
                   //Creating the Alert
                   UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sorry"
                                                                                              message:@"It seems that there were no similar movies found"
                                                                                       preferredStyle:(UIAlertControllerStyleAlert)];
                   
                   // create an try again action
                   UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                      style:UIAlertActionStyleCancel
                                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                                            // handle response here.
                                                                    }];
                   // add the try again action to the alert controller
                   [alert addAction:cancelAction];
                   
                   [self presentViewController:alert animated:YES completion:^{
                       // optional code for what happens after the alert controller has finished presenting
                   }];
               }
               
               
                   [self.collectionView reloadData];
               NSLog(@"%lu", (unsigned long)self.similarMovies.count);
               for (NSDictionary *movie in self.similarMovies){
                   NSLog(@"%@", movie[@"title"]);
               }
               
           }
        [self.refreshControl endRefreshing];
       }];
    
    [task resume];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MovieCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionCell" forIndexPath:indexPath];
    
    NSDictionary *movie = self.similarMovies[indexPath.item];
    
    if ([movie[@"poster_path"] isKindOfClass:[NSString class]]) {
        NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
        NSString *posterURL = movie[@"poster_path"];
    //    NSLog(@"%@", posterURL);
        NSString *fullPosterURLString = [baseURLString stringByAppendingString: posterURL];
        
        NSURL *fullPosterURL = [NSURL URLWithString:fullPosterURLString];
        cell.similarPosterImage.image = nil;
        cell.similarPosterImage.backgroundColor = UIColor.clearColor;
        [cell.similarPosterImage setImageWithURL:fullPosterURL];
    }
    else if ([movie[@"backdrop_path"] isKindOfClass:[NSString class]]){
        NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
        NSString *backdropURL = movie[@"backdrop_path"];
        NSString *fullBackdropURLString = [baseURLString stringByAppendingString: backdropURL];
        NSURL *backdropPosterURL = [NSURL URLWithString:fullBackdropURLString];
        cell.similarPosterImage.image = nil;
        cell.similarPosterImage.backgroundColor = UIColor.clearColor;
        [cell.similarPosterImage setImageWithURL:backdropPosterURL];
    }
    else{
        cell.similarPosterImage.image = [UIImage imageNamed:@"reel_tabbar_icon"];
        cell.similarPosterImage.backgroundColor = [UIColor colorWithRed:148.0f/255.0f
                                                                  green:17.0f/255.0f
                                                                   blue:0.0f/255.0f
                                                                  alpha:1.0f];
    }
    
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  self.similarMovies.count;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UICollectionViewCell *tappedCell = sender;
       NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
    NSDictionary *movie = self.similarMovies[indexPath.row];
    DetailsViewController *detailController = [segue destinationViewController];
    
    detailController.movie = movie;
}


@end
