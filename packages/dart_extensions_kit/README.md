# dart_extensions_kit

description: A comprehensive collection of useful extension methods for Dart and Flutter, including
utilities for numbers, strings, lists, maps, dates, colors, and booleans.

## Features

### Int Extensions
- `isEven` - Check if number is even
- `isOdd` - Check if number is odd
- `toBinary` - Convert to binary string
- `toOctal` - Convert to octal string
- `toHexUpperCase` - Convert to uppercase hex string
- `toHexLowerCase` - Convert to lowercase hex string
- `toFileSize` - Convert bytes to human readable file size
- `isPrime` - Check if number is prime
- `factorial` - Get factorial of number
- `fibonacci` - Get fibonacci number
- `factors` - Get all factors
- `primeFactors` - Get prime factors
- `gcd(other)` - Get greatest common divisor
- `toRoman` - Convert to Roman numerals
- `formatted` - Format number with thousand separators
- `repeat(str)` - Repeat string n times
- `times<T>(generator)` - Create list with generator function
- `timesValue<T>(value)` - Create list filled with value

### Int Time Extensions (int?)
- `formatMillisToSmartTime` - Format millis to smart time string
- `formatSecondsToSmartTime` - Format seconds to MM:SS or HH:MM:SS
- `formatSecondsToHms` - Format seconds to HH:MM:SS
- `formatSecondsToHms2` - Alternative format seconds to HH:MM:SS
- `formatMillisToHms` - Format milliseconds to HH:MM:SS
- `formatSecondsToCompact` - Format seconds to compact string (e.g., "2h23m12s")
- `isWithinMinutes(other, minutes)` - Check if within specified minutes
- `toDate` - Convert timestamp to DateTime

### Double Extensions
- `isInteger` - Check if double is integer
- `roundTo(decimals)` - Round to specified decimal places
- `ceilTo(decimals)` - Ceil to specified decimal places
- `floorTo(decimals)` - Floor to specified decimal places
- `toPercentage(decimals)` - Convert to percentage string
- `squared` - Get square of number
- `cubed` - Get cube of number
- `toDegrees` - Convert radians to degrees
- `toRadians` - Convert degrees to radians

### Price Formatting Extensions (double)
- `toCurrency(symbol, decimals)` - Convert to currency string
- `toPriceStringSimple()` - Simple price string (remove trailing .0)
- `toPriceString()` - Smart price string with NumberFormat

### Num Extensions
- `isPositive` - Check if positive
- `isNegative` - Check if negative
- `isZero` - Check if zero
- `clamp(min, max)` - Clamp value to range
- `isInRange(min, max)` - Check if in range (inclusive)
- `isInRangeExclusive(min, max)` - Check if in range (exclusive)
- `lerp(other, t)` - Linear interpolation
- `max(other)` - Get maximum value
- `min(other)` - Get minimum value
- `isEven` - Check if even
- `isOdd` - Check if odd
- `formatted` - Format with thousand separators

### String Extensions
- `isBlank` - Check if blank (null, empty, or whitespace only)
- `isNotBlank` - Check if not blank
- `isNullString` - Check if string is "null" (case insensitive)
- `capitalize` - Capitalize first letter
- `unCapitalize` - Uncapitalize first letter
- `toSnakeCase` - Convert camelCase to snake_case
- `toCamelCase` - Convert snake_case to camelCase
- `truncate(maxLength, suffix)` - Truncate with ellipsis
- `removeHtmlTags` - Remove HTML tags
- `isEmail` - Check if valid email format
- `isPhoneNumber` - Check if valid Chinese phone number
- `isUrl` - Check if valid URL format
- `tryToInt()` - Try to parse as int
- `tryToDouble()` - Try to parse as double
- `toColor` - Convert hex string to Color
- `reversed` - Reverse string
- `repeat(times)` - Repeat string
- `remove(char)` - Remove character
- `removeAll(chars)` - Remove multiple characters
- `containsNumber` - Check if contains numbers
- `isNumeric` - Check if only contains numbers
- `isAlphabetic` - Check if only contains letters
- `isAlphanumeric` - Check if only contains letters and numbers

### Nullable String Extensions (String?)
- `toIntOr(defaultValue)` - Parse to int with default
- `toDoubleOr(defaultValue)` - Parse to double with default
- `isNullOrEmpty` - Check if null or empty
- `isNotNullOrEmpty` - Check if not null and not empty
- `isNullOrBlank` - Check if null or blank
- `isNotNullOrBlank` - Check if not null and not blank
- `toBool` - Parse to bool (loose)
- `toBoolStrict()` - Parse to bool (strict)

### Enum Parsing Extensions
- `toEnum<T>(values, defaultValue, ignoreCase)` - Parse string to enum
- `toEnumOr<T>(values, defaultValue, ignoreCase)` - Parse string to enum with default

### List Extensions
- `getOrNull(index)` - Safe get element, return null if out of bounds
- `getOrDefault(index, defaultValue)` - Safe get element with default
- `randomOrNull` - Get random element or null
- `randomOrDefault(defaultValue)` - Get random element with default
- `shuffled` - Get shuffled copy
- `distinct` - Remove duplicates (preserve order)
- `distinctBy(keySelector)` - Remove duplicates by key
- `chunk(chunkSize)` - Split into chunks
- `removeFirstWhere(test)` - Remove first matching element
- `insertSafe(index, element)` - Safe insert at index
- `swap(index1, index2)` - Swap elements
- `count(test)` - Count matching elements
- `firstWhereOrNull(test)` - Get first matching element or null
- `lastWhereOrNull(test)` - Get last matching element or null
- `indexWhereOrNull(test)` - Get index of first match or null
- `lastIndexWhereOrNull(test)` - Get index of last match or null
- `isValidIndex(index)` - Check if index is valid
- `sublistSafe(start, end)` - Safe sublist
- `addIfNotNull(element)` - Add if not null
- `addAllNotNull(elements)` - Add all non-null elements
- `prepend(element)` - Add to beginning
- `prependAll(elements)` - Add all to beginning
- `middle` - Get middle element
- `firstHalf` - Get first half
- `secondHalf` - Get second half
- `hasDuplicates` - Check if has duplicates
- `duplicates` - Get duplicate elements
- `unique` - Get unique elements (appear only once)

### Nullable List Extensions (List<T>?)
- `isEmptyOrNull` - Check if null or empty
- `isNotEmptyOrNull` - Check if not null and not empty

### String List Filter Extensions
- `whereNotNullOrEmpty(ignoreWhitespaceOnly)` - Filter null and empty strings

### Enum Helper Extensions
- `fromEnumName(name, defaultValue)` - Get enum by name
- `fromEnumNameOr(name, defaultValue)` - Get enum by name with default

### Map Extensions
- `getOrNull(key)` - Safe get value, return null if key doesn't exist
- `getOrDefault(key, defaultValue)` - Safe get value with default
- `getOrPut(key, defaultValue)` - Get or put value
- `getOrPutAsync(key, defaultValue)` - Get or put value (async)
- `removeWhere(test)` - Remove matching key-value pairs
- `keysList` - Get keys as list
- `valuesList` - Get values as list
- `entriesList` - Get entries as list
- `reversed` - Reverse key-value pairs
- `filterValues(test)` - Filter by values
- `filterKeys(test)` - Filter by keys
- `mapValues<R>(transform)` - Transform values
- `mapKeys<R>(transform)` - Transform keys
- `merge(other)` - Merge with another map
- `deepMerge(other)` - Deep merge with another map
- `firstEntry` - Get first entry
- `lastEntry` - Get last entry
- `containsValue(value)` - Check if contains value
- `keysSet` - Get keys as set
- `valuesSet` - Get values as set
- `sortedByValue(compare)` - Sort by values
- `sortedByKey(compare)` - Sort by keys
- `minByValue` - Get entry with minimum value
- `maxByValue` - Get entry with maximum value
- `sumValues()` - Sum numeric values
- `averageValues()` - Average numeric values
- `groupByValue()` - Group by values
- `allValues(test)` - Check if all values match
- `anyValue(test)` - Check if any value matches
- `allKeys(test)` - Check if all keys match
- `anyKey(test)` - Check if any key matches

### Nullable Map Extensions (Map<K, V>?)
- `isEmptyOrNull` - Check if null or empty
- `isNotEmptyOrNull` - Check if not null and not empty

### DateTime Extensions
- `getWeekdayName(pattern, locale)` - Get weekday name
- `getWeekdayNameShort(locale)` - Get short weekday name
- `weekdayEn` - Get weekday in English
- `weekdayShortEn` - Get short weekday in English
- `weekdayCn` - Get weekday in Chinese
- `weekdayShortCn` - Get short weekday in Chinese
- `getMonthName(pattern, locale)` - Get month name
- `getMonthNameShort(locale)` - Get short month name
- `monthEn` - Get month in English
- `monthShortEn` - Get short month in English
- `isToday` - Check if today
- `isYesterday` - Check if yesterday
- `isTomorrow` - Check if tomorrow
- `isThisWeek` - Check if this week
- `isThisMonth` - Check if this month
- `isThisYear` - Check if this year
- `startOfMonth` - Get start of month
- `endOfMonth` - Get end of month
- `startOfYear` - Get start of year
- `endOfYear` - Get end of year
- `startOfWeek` - Get start of week (Monday)
- `endOfWeek` - Get end of week (Sunday)
- `formatDate` - Format as yyyy-MM-dd
- `formatTime` - Format as HH:mm:ss
- `formatDateTime` - Format as yyyy-MM-dd HH:mm:ss
- `formatDateTimeShort` - Format as yyyy-MM-dd HH:mm
- `formatMillisToSmartTime(locale)` - Smart time formatting
- `relativeTime` - Get relative time description
- `age` - Get age in years
- `addYears(years)` - Add years
- `addMonths(months)` - Add months
- `addDays(days)` - Add days
- `addHours(hours)` - Add hours
- `addMinutes(minutes)` - Add minutes
- `addSeconds(seconds)` - Add seconds
- `subtractYears(years)` - Subtract years
- `subtractMonths(months)` - Subtract months
- `subtractDays(days)` - Subtract days
- `subtractHours(hours)` - Subtract hours
- `subtractMinutes(minutes)` - Subtract minutes
- `subtractSeconds(seconds)` - Subtract seconds
- `setTime(hour, minute, second, millisecond, microsecond)` - Set time
- `setDate(year, month, day)` - Set date
- `isWorkday` - Check if workday
- `isWeekend` - Check if weekend
- `quarter` - Get quarter
- `startOfQuarter` - Get start of quarter
- `endOfQuarter` - Get end of quarter

### Color Extensions
- `hex` - Get hex string with alpha
- `hexRGB` - Get hex string without alpha
- `rgb` - Get RGB string
- `rgba` - Get RGBA string
- `hsl` - Get HSL values
- `hslString` - Get HSL string
- `isDark` - Check if dark color
- `isLight` - Check if light color
- `contrastColor` - Get contrast color (black or white)
- `luminance` - Get luminance
- `withBrightness(brightness)` - Adjust brightness
- `withSaturation(saturation)` - Adjust saturation
- `withHue(hue)` - Adjust hue
- `withOpacity(opacity)` - Adjust opacity
- `blend(other, ratio)` - Blend with another color
- `complementary` - Get complementary color
- `analogous` - Get analogous color
- `triadic` - Get triadic colors
- `monochromatic` - Get monochromatic colors
- `fromHex(hex)` - Create color from hex string
- `fromRGB(r, g, b, a)` - Create color from RGB values
- `fromHSL(h, s, l, a)` - Create color from HSL values

### Bool Extensions
- `toInt` - Convert to int (true=1, false=0)
- `toChinese` - Convert to Chinese (是/否)

### Nullable Bool Extensions (bool?)
- `isTrue` - Check if true


## Installation

Add the dependency in `pubspec.yaml`:

```yaml 
dependencies:
  dart_extensions_kit: ^1.0.0
```

Then run:

``` bash
flutter pub get
```

## Usage

Please check the example.

## Example

See the example directory for a complete sample app.

## License

The project is under the MIT license.