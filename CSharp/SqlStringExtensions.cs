/// <summary>
/// Extension methods for working with SQL Strings
/// </summary>
public static class SqlStringExtensions
{
	/// <summary>
	/// Replicates the source string n times
	/// </summary>
	/// <param name="value"></param>
	/// <param name="repetitions"></param>
	/// <returns></returns>
	public static string Replicate(this string value, int repetitions)
		=> new StringBuilder(value.Length * repetitions).Insert(0, value, repetitions).ToString();

	/// <summary>
	/// Escapes all instances of left and right in the string, then wraps them in the respective values.
	/// </summary>
	/// <typeparam name="T"></typeparam>
	/// <param name="value"></param>
	/// <param name="left">Value to wrap on the left</param>
	/// <param name="right">Value to wrap on the right. If same as left, only left is processed.</param>
	/// <returns></returns>
	public static string QuoteName<T>(this T value, string left, string right)
	{
		var strVal = value.ToString();
		// Replace the left character
		strVal = strVal.Replace(left, left.Replicate(2));
		// Assuming left and right are different, replace the right character.
		if (left != right)
		{
			strVal = strVal.Replace(right, right.Replicate(2));
		}
		// Wrap string in left/right values
		strVal = $"{left}{strVal}{right}";
		return strVal;
	}

	/// <summary>
	/// Default QuoteName wraps string in square brackets
	/// </summary>
	/// <typeparam name="T"></typeparam>
	/// <param name="value"></param>
	/// <returns></returns>
	public static string QuoteName<T>(this T value)
		=> value.QuoteName("[", "]");
	/// <summary>
	/// QuoteNames a string with a symmetric wrapper value
	/// </summary>
	/// <typeparam name="T"></typeparam>
	/// <param name="value">Value to be quotenamed</param>
	/// <param name="character">Default is single quote (')</param>
	/// <returns></returns>
	public static string QuoteName<T>(this T value, string character = "'")
		=> value.QuoteName(character, character);
}