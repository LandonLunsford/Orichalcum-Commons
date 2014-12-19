package orichalcum.utility 
{
	import flash.media.SoundMixer;
	import flash.utils.ByteArray;
	import orichalcum.utility.Mathematics;

	/*
	 * SoundMixer.computeSpectrum
	 * Takes a snapshot of the current sound wave and places it into the specified ByteArray object.
	 * The values are formatted as normalized floating-point values, in the range -1.0 to 1.0.
	 * The ByteArray object passed to the outputArray parameter is overwritten with the new values.
	 * The size of the ByteArray object created is fixed to 512 floating-point values,
	 * where the first 256 values represent the left channel,
	 * and the second 256 values represent the right channel.
	 */
	public class SoundMixers 
	{
		
		static public function computeSpectrumAsArray():Array
		{
			const soundSpectrum:ByteArray = new ByteArray;
			const soundSpectrumValues:Array = [];
			SoundMixer.computeSpectrum(soundSpectrum);
			for (var i:int = 0; i < 512; i++)
			{
				soundSpectrumValues[soundSpectrumValues.length] = soundSpectrum.readFloat();
			}
			return soundSpectrumValues;
		}
		
		static public function computeSpectrumAverage():Number
		{
			return Mathematics.average.apply(null, computeSpectrumAsArray());
		}
		
	}

}