<?php

if($_SERVER['argc'] !== 3) {
	echo "php patch.php <mode> <what>";
	exit(0);
}

list($Script,$Mode,$What) = $_SERVER['argv'];

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

$Files = [
	'sfnone' => [
		'scripts\source\dse_dm_ExternSexFrameworkInterface.psc'
		=> 'patches\dse_dm_ExternSexFrameworkInterface-None.psc',
		'scripts\dse_dm_ExternSexFrameworkInterface.pex'
		=> 'patches\dse_dm_ExternSexFrameworkInterface-None.pex'
	],
	'sfsl' => [
		'scripts\source\dse_dm_ExternSexFrameworkInterface.psc'
		=> 'patches\dse_dm_ExternSexFrameworkInterface-SexLab.psc',
		'scripts\dse_dm_ExternSexFrameworkInterface.pex'
		=> 'patches\dse_dm_ExternSexFrameworkInterface-SexLab.pex'
	],
	'sfos' => [
		'scripts\source\dse_dm_ExternSexFrameworkInterface.psc'
		=> 'patches\dse_dm_ExternSexFrameworkInterface-OStim.psc',
		'scripts\dse_dm_ExternSexFrameworkInterface.pex'
		=> 'patches\dse_dm_ExternSexFrameworkInterface-OStim.pex'
	]
];

function CopyTheFiles(array $Input) {

	$Prefix = getcwd();

	foreach($Input as $Src => $Dest)
	copy(
		"{$Prefix}\\{$Src}",
		"{$Prefix}\\{$Dest}"
	);

	return;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

if(!array_key_exists($What,$Files))
throw new Exception('invalid what');

switch($Mode) {
	case 'push':
		CopyTheFiles(array_flip($Files[$What]));
	break;
	case 'pull':
		CopyTheFiles($Files[$What]);
	break;
	default:
		throw new Exception('invalid mode');
	break;
}
