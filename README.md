# JTSSwiftTweener
This class allows the animation of arbitrary numeric values. Now completely rebuilt for Swift 3.

### Usage

Tweeners are created by calling the static `tween` method:

```
public static func tween(duration: CFTimeInterval, 
						 from: Double = 0.0, 
						 to: Double = 1.0, 
						 easing: TweenerEasing.EasingTransform, 
						 progress: TweenProgress, 
						 completion: TweenComplete?) -> Tweener
```

You may choose to hold on to the returned Twenner if you want to have the ability to cancel it prior to its completion. However, you will need to be careful not to create a retain cycle in the progress and completion closures.