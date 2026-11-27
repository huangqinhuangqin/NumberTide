#import "NumberTideWyViewController.h"
#import <NumberTideSDK/NumberTideSDK.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import <SafariServices/SafariServices.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import <WebKit/WebKit.h>

@interface NumberTideWyViewController () <WKNavigationDelegate, WKUIDelegate,
                                           NumberTideSDKDelegate,
                                           PHPickerViewControllerDelegate,
                                           UIDocumentPickerDelegate>
@property (nonatomic, copy) NSString *numberTideIDFA;
@property (nonatomic, copy) NSString *numberTideIDFV;
@property (nonatomic, strong) WKWebView *numberTideWebView;
@property (nonatomic, copy) void (^numberTideMediaCompletion)(NSData *, NSString *, BOOL);
@end

@implementation NumberTideWyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSString *storedIDFA = [defaults stringForKey:@"IDFA"];
    self.numberTideIDFA = storedIDFA.length
        ? storedIDFA
        : @"00000000-0000-0000-0000-000000000000";
    self.numberTideIDFV = [defaults stringForKey:@"IDFV"] ?: @"";
    self.view.backgroundColor = [UIColor colorWithRed:24.0 / 255.0
                                                green:24.0 / 255.0
                                                 blue:25.0 / 255.0
                                                alpha:1.0];
    WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
    configuration.websiteDataStore = WKWebsiteDataStore.defaultDataStore;
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    webView.underPageBackgroundColor = self.view.backgroundColor;
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    webView.navigationDelegate = self;
    webView.UIDelegate = self;
    webView.allowsBackForwardNavigationGestures = YES;
    webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.view addSubview:webView];
    [NSLayoutConstraint activateConstraints:@[
        [webView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [webView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [webView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
    self.numberTideWebView = webView;
    [self numberTideAttachSDKAndLoadWebView];
}

- (void)numberTideAttachSDKAndLoadWebView {
    NumberTideSDK *sdk = NumberTideSDK.numberTideShared;
    sdk.numberTideDelegate = self;
    [sdk numberTideAttachToWebView:self.numberTideWebView completion:^(BOOL success, NSError *error) {
        if (!success)
            return;
        NSURL *url = [self numberTideURLWithIdentifiers:sdk.numberTideConfiguration.numberTideHFiveNoLinkStr];
        if (url)
            [self.numberTideWebView loadRequest:[NSURLRequest requestWithURL:url]];
    }];
}

- (NSURL *)numberTideURLWithIdentifiers:(NSURL *)url {
    if (!url)
        return nil;
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    if (!components)
        return nil;
    NSMutableArray<NSURLQueryItem *> *items = [components.queryItems mutableCopy] ?: [NSMutableArray array];
    NSIndexSet *oldItems = [items indexesOfObjectsPassingTest:^BOOL(NSURLQueryItem *item, NSUInteger idx, BOOL *stop) {
        return [item.name isEqualToString:@"IDFA"] || [item.name isEqualToString:@"IDFV"];
    }];
    [items removeObjectsAtIndexes:oldItems];
    NSString *idfa = self.numberTideIDFA.length
        ? self.numberTideIDFA
        : @"00000000-0000-0000-0000-000000000000";
    [items addObject:[NSURLQueryItem queryItemWithName:@"IDFA" value:idfa]];
    [items addObject:[NSURLQueryItem queryItemWithName:@"IDFV" value:self.numberTideIDFV ?: @""]];
    components.queryItems = items;
    return components.URL;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [NumberTideSDK.numberTideShared numberTideWebViewDidStartNavigation:webView];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [NumberTideSDK.numberTideShared numberTideWebViewDidFinishNavigation:webView];
}

- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)action
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = action.request.URL;
    if (action.targetFrame && !action.targetFrame.isMainFrame) {
        NSString *scheme = url.scheme.lowercaseString;
        BOOL webURL = [scheme isEqualToString:@"https"] && [self numberTideWaveLink:url];
        BOOL localFrameURL = [@[@"about", @"blob", @"data"] containsObject:scheme];
        decisionHandler((webURL || localFrameURL) ? WKNavigationActionPolicyAllow
                                                  : WKNavigationActionPolicyCancel);
        return;
    }
    if ([self numberTideKexingMatch:url] || [self numberTideNumberActionMatch:url]) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    if ((!action.targetFrame || action.targetFrame.isMainFrame) && [self numberTideWaveLink:url])
        [self numberTideOpenURLInApp:url];
    decisionHandler(WKNavigationActionPolicyCancel);
}

- (WKWebView *)webView:(WKWebView *)webView
    createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
               forNavigationAction:(WKNavigationAction *)navigationAction
                    windowFeatures:(WKWindowFeatures *)windowFeatures {
    NSURL *url = navigationAction.request.URL;
    if ([self numberTideKexingMatch:url] || [self numberTideNumberActionMatch:url])
        [webView loadRequest:navigationAction.request];
    else if ([self numberTideWaveLink:url])
        [self numberTideOpenURLInApp:url];
    return nil;
}

- (BOOL)numberTideKexingMatch:(NSURL *)url {
    NSURL *trusted = [NSURL URLWithString:NumberTideSDK.numberTideShared.numberTideConfiguration.numberTideKexingStyle ?: @""];
    return [self numberTideURL:url matchesOrigin:trusted];
}

- (BOOL)numberTideNumberActionMatch:(NSURL *)url {
    if (!url || ![url.scheme.lowercaseString isEqualToString:@"https"] || url.user || url.password || url.port)
        return NO;
    return [NumberTideSDK.numberTideShared.numberTideConfiguration.numberTideNumberActionHosts
        containsObject:url.host.lowercaseString ?: @""];
}

- (BOOL)numberTideWaveLink:(NSURL *)url {
    return url && !url.user && !url.password && url.host.length &&
           [@[@"http", @"https"] containsObject:url.scheme.lowercaseString];
}

- (BOOL)numberTideURL:(NSURL *)url matchesOrigin:(NSURL *)origin {
    if (!url || !origin)
        return NO;
    NSNumber *(^effectivePort)(NSURL *) = ^NSNumber *(NSURL *value) {
        if (value.port)
            return value.port;
        return [value.scheme.lowercaseString isEqualToString:@"https"] ? @443 : @80;
    };
    return [url.scheme.lowercaseString isEqualToString:origin.scheme.lowercaseString] &&
           [url.host.lowercaseString isEqualToString:origin.host.lowercaseString] &&
           [effectivePort(url) isEqualToNumber:effectivePort(origin)];
}

- (void)numberTideOpenURLInApp:(NSURL *)url {
    [self presentViewController:[[SFSafariViewController alloc] initWithURL:url]
                       animated:YES completion:nil];
}

- (void)numberTideSDK:(NumberTideSDK *)sdk
               openURL:(NSURL *)url
         preferredMode:(NSString *)preferredMode
            completion:(void (^)(BOOL, NSString *))completion {
    if ([preferredMode isEqualToString:@"inAppBrowser"] &&
        [@[@"http", @"https"] containsObject:url.scheme.lowercaseString]) {
        SFSafariViewController *controller = [[SFSafariViewController alloc] initWithURL:url];
        [self presentViewController:controller animated:YES completion:^{
            completion(YES, @"inAppBrowser");
        }];
        return;
    }
    if ([preferredMode isEqualToString:@"inAppBrowser"]) {
        completion(NO, @"inAppBrowser");
        return;
    }
    [UIApplication.sharedApplication openURL:url options:@{} completionHandler:^(BOOL success) {
        completion(success, @"externalBrowser");
    }];
}

- (void)numberTideSDK:(NumberTideSDK *)sdk
    requestMediaFromSource:(NSString *)source
                completion:(void (^)(NSData *, NSString *, BOOL))completion {
    if (self.numberTideMediaCompletion) {
        completion(nil, nil, NO);
        return;
    }
    self.numberTideMediaCompletion = completion;
    if ([source isEqualToString:@"file"]) {
        UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc]
            initForOpeningContentTypes:@[UTTypeJPEG, UTTypePNG] asCopy:YES];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
        return;
    }
    PHPickerConfiguration *configuration =
        [[PHPickerConfiguration alloc] initWithPhotoLibrary:PHPhotoLibrary.sharedPhotoLibrary];
    configuration.filter = PHPickerFilter.imagesFilter;
    configuration.selectionLimit = 1;
    PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:configuration];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results {
    [picker dismissViewControllerAnimated:YES completion:nil];
    PHPickerResult *result = results.firstObject;
    if (!result) {
        [self numberTideCompleteMedia:nil filename:nil cancelled:YES];
        return;
    }
    NSString *type = [result.itemProvider hasItemConformingToTypeIdentifier:UTTypePNG.identifier]
                         ? UTTypePNG.identifier : UTTypeJPEG.identifier;
    [result.itemProvider loadDataRepresentationForTypeIdentifier:type completionHandler:^(NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *filename = [type isEqualToString:UTTypePNG.identifier] ? @"upload.png" : @"upload.jpg";
            [self numberTideCompleteMedia:data filename:filename cancelled:NO];
        });
    }];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller
    didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *url = urls.firstObject;
    BOOL scoped = [url startAccessingSecurityScopedResource];
    NSData *data = url ? [NSData dataWithContentsOfURL:url options:0 error:nil] : nil;
    if (scoped)
        [url stopAccessingSecurityScopedResource];
    [self numberTideCompleteMedia:data filename:url.lastPathComponent cancelled:NO];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    [self numberTideCompleteMedia:nil filename:nil cancelled:YES];
}

- (void)numberTideCompleteMedia:(NSData *)data filename:(NSString *)filename cancelled:(BOOL)cancelled {
    void (^completion)(NSData *, NSString *, BOOL) = self.numberTideMediaCompletion;
    self.numberTideMediaCompletion = nil;
    if (completion)
        completion(data, filename, cancelled);
}

- (void)numberTideSDK:(NumberTideSDK *)sdk
          saveImageData:(NSData *)data
       suggestedFilename:(NSString *)filename
              completion:(void (^)(BOOL))completion {
    [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelAddOnly handler:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized && status != PHAuthorizationStatusLimited) {
            completion(NO);
            return;
        }
        [PHPhotoLibrary.sharedPhotoLibrary performChanges:^{
            PHAssetResourceCreationOptions *options = [PHAssetResourceCreationOptions new];
            options.originalFilename = filename;
            [[PHAssetCreationRequest creationRequestForAsset]
                addResourceWithType:PHAssetResourceTypePhoto data:data options:options];
        } completionHandler:^(BOOL success, NSError *error) {
            completion(success);
        }];
    }];
}

- (void)dealloc {
    [NumberTideSDK.numberTideShared numberTideDetachFromWebView:self.numberTideWebView];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
