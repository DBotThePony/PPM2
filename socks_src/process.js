
//
// Copyright (C) 2017 DBot
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

const fs = require('fs');
const child_process = require('child_process');
const spawn = child_process.spawn;

const images = [];

for (let i = 1; i <= 8; i++)
//for (let i = 1; i <= 2; i++)
    images.push('geometric' + i);

try {
    fs.statSync('./output');
} catch(err) {
    fs.mkdirSync('./output');
}

const colorMatching = /[0-9]+,[0-9]+: ?\([0-9]+,[0-9]+,[0-9]+\) *#[0-9ABCDEF]+ +(.*)\r?\n?/;

let currentI = 0;
function proceed() {
    currentI++;
    if (!images[currentI - 1]) return;
    const image = images[currentI - 1];
    const imageF = 'raw/' + images[currentI - 1];
    const imageO = 'output/' + images[currentI - 1] + '_raw';
    const imageO2 = 'output/' + images[currentI - 1];

    const magick = spawn('magick', [
        'convert', imageF + '.png', '-resize', '2048x2048!',
        '-contrast-stretch', '99%', '-fill', 'black',
        '-opaque', 'white', '+write', imageO + '.png',
        '-unique-colors', 'txt:'
    ]);

    console.log(`Processing ${imageF}`);

    let outputColors;

    magick.stdout.on('data', (buff) => {outputColors += buff.toString()});
    magick.stderr.pipe(process.stderr);

    magick.on('close', code => {
        if (code != 0) process.exit(code);
        const lines = outputColors.split(/\r?\n/);
        lines.splice(0, 1);
        const colors = [];

        for (const line of lines) {
            const match = line.match(colorMatching);
            if (!match) continue;
            const color = match[1];
            colors.push(color);
        }

        console.log(`${imageF} contains ${lines.length} unique colors`);

        let i = 1;
        const newArgs = ['convert', imageO + '.png'];

        for (const color of colors) {
            newArgs.push('(', '-clone', '0', '+transparent', color, '-channel', 'RGB', '+level-colors', 'white', '-channel', 'ALL', '+write', `${imageO2}_${i}.png`, ')', '+delete');
            i++;
        }

        const magick2 = spawn('magick', newArgs);
        magick2.stdout.pipe(process.stdout);
        magick2.stderr.pipe(process.stderr);

        magick2.on('close', code => {
            //if (code != 0) process.exit(code);
            console.log(`Saved as ${imageO}`);
            proceed();
        })
    });
}

proceed();
