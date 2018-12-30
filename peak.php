<?php
function getMaxDepth(array $array) {
	// $array = json_encode($array);
	// $array = preg_replace('/[^\[\]\{\}]/', '', $array);
	// $array = str_replace(['{', '}'], ['[', ']'], $array);
	$array = str_replace(['{', '}'], ['[', ']'], preg_replace('/[^\[\]\{\}]/', '', json_encode($array)));
	$count = 0;
	while ($array) {
		$array = str_replace('[]', '', $array);
		$count++;
	}
	return $count;
}
$array = [];
for ($i = 0; $i < 10; $i++) {
	$array[$i][] = [$i];
	for ($j = 0; $j < 10; $j++) {
		$array[$i][$j][] = [[$i], [$j]];
		$array[$j][$i][] = [[$i], [$j]];
	}
}
// $array = [1, 2, ['tr', 5, 6 => [3, 2, 'dfgh', 'uuu' => [8,9]]]];
echo 'peak: ' . getMaxDepth($array)."\n";
echo max(array_map('count', $array))."\n";
print_r($array);