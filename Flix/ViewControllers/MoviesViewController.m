//
//  MoviesViewController.m
//  Flix
//
//  Created by Harleen Kaur on 6/23/21.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

//UITableViewDelegate & DataSource import
@interface MoviesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic,strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Making sure the data source and delegate know where to look
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Start the activity indicator
    [self.activityIndicator startAnimating];
    [self.view bringSubviewToFront:self.activityIndicator];
    
    [self fetchMovies];
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void) fetchMovies {
    // Getting the API
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
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
                                                                        // Start the activity indicator
                                                                        [self.activityIndicator startAnimating];
                                                                        [self.view bringSubviewToFront:self.activityIndicator];
                   
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
                   self.movies = dataDictionary[@"results"];
                   // TODO: Store the movies in a property to use elsewhere
                   // TODO: Reload your table view data
                   [self.tableView reloadData];
               
           }
        [self.activityIndicator stopAnimating];
        [self.refreshControl endRefreshing];
       }];
    
    [task resume];
}

- (NSInteger) tableView: (UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.movies.count;
}

- (UITableViewCell *) tableView: (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    NSDictionary *movie = self.movies[indexPath.row];
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURL = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString: posterURL];
    
    NSURL *fullPosterURL = [NSURL URLWithString:fullPosterURLString];
    cell.posterImage.image = nil;
    
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    [cell.posterImage setImageWithURL:fullPosterURL];
    return cell;
}





#pragma mark - Navigation
//Function that passes on something to the new view controller when the movie is clicked for more detail

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.movies[indexPath.row];
    DetailsViewController *detailController = [segue destinationViewController];
    
    detailController.movie = movie;
}


@end
