//
//  ViewController.m
//  MapKitLocation
//
//  Created by DT on 16/3/24.
//  Copyright © 2016年 tiannuo. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *lm;

/** 地理编码 */
@property (strong, nonatomic) CLGeocoder *geoc;
@property (weak, nonatomic) IBOutlet UILabel *currentLocation;  // 当前位置显示
- (IBAction)getMyLocation:(id)sender;   // 获取当前位置按钮
@property (weak, nonatomic) IBOutlet UITextField *latitudeText; // 纬度输入框
@property (weak, nonatomic) IBOutlet UITextField *longtitudeText;   // 经度输入框
- (IBAction)getCodeLocation:(id)sender; // 地理编码
- (IBAction)getReverseLocation:(id)sender;  // 反地理编码
@property (weak, nonatomic) IBOutlet UITextView *inputLocation; // 地址输入框
@end

@implementation ViewController

- (CLGeocoder *)geoc
{
    if (!_geoc) {
        _geoc = [[CLGeocoder alloc] init];
    }
    return _geoc;
}

- (CLLocationManager *)lm
{
    if (!_lm) {
        _lm = [[CLLocationManager alloc] init];
        _lm.delegate = self;
        [_lm startUpdatingLocation];
        if ([_lm respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [_lm requestAlwaysAuthorization];
        }
    }
    return _lm;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - CoreLocation 代理
#pragma mark 跟踪定位代理方法，每次位置发生变化即会执行（只要定位到相应位置）
//可以通过模拟器设置一个虚拟位置，否则在模拟器中无法调用此方法
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location=[locations firstObject];//取出第一个位置
    CLLocationCoordinate2D coordinate=location.coordinate;//位置坐标
    NSLog(@"经度：%f,纬度：%f,海拔：%f,航向：%f,行走速度：%f",coordinate.longitude,coordinate.latitude,location.altitude,location.course,location.speed);
    //如果不需要实时定位，使用完即使关闭定位服务
    [_lm stopUpdatingLocation];
    
    // 反地理编码
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [self.geoc reverseGeocodeLocation:loc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (error == nil) {
            NSLog(@"%@", placemarks);
            [placemarks enumerateObjectsUsingBlock:^(CLPlacemark * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSLog(@"%@", obj.name);
                self.currentLocation.text = obj.name;
            }];
        }
    }];
    
    
}

// 获得当前位置按钮
- (IBAction)getMyLocation:(id)sender {
    [self lm];
    self.mapView.showsUserLocation = YES;
}

// 地理编码
- (IBAction)getCodeLocation:(id)sender {
    self.longtitudeText.text = @"";
    self.latitudeText.text = @"";
    
    NSString *addr = self.inputLocation.text;
    if (addr.length == 0) {
        return;
    }

    [self.geoc geocodeAddressString:addr completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error == nil) {
            NSLog(@"%@", placemarks);
            [placemarks enumerateObjectsUsingBlock:^(CLPlacemark * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSLog(@"%@", obj.name);
                self.longtitudeText.text = @(obj.location.coordinate.longitude).stringValue;
                self.latitudeText.text = @(obj.location.coordinate.latitude).stringValue;
            }];
        } else {
            NSLog(@"地理编码失败---%@", error.localizedDescription);
        }
    }];
}

// 反地理编码
- (IBAction)getReverseLocation:(id)sender {
   
    self.inputLocation.text = @"";
    double lati = [self.latitudeText.text doubleValue];
    double longti = [self.longtitudeText.text doubleValue];
    
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:lati longitude:longti];
    [self.geoc reverseGeocodeLocation:loc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (error == nil) {
            NSLog(@"%@", placemarks);
            [placemarks enumerateObjectsUsingBlock:^(CLPlacemark * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSLog(@"%@", obj.name);
                self.inputLocation.text = obj.name;
            }];
        }
    }];
    
    
}
@end
