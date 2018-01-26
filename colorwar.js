<script type="text/javascript">

			var canvas;
			var ctx;
			var width = 600;
			var height = 600;
			var startinc = 10;
			var inc;
			var dx;
			var dy;
			var reds;
			var greens;
			var blues;
			var red_tab;
			var green_tab;
			var blue_tab;
			var interval_millies = 10;
			var loopcount = 1000;
			var interval_id;
			var numcolors = 128;
						
			
			function restart()
			{
				clearInterval(interval_id);
				init();
			}
			
			function setsize(c)
			{
				startinc = c;
				restart();
			}

			function setcolors(c)
			{
				numcolors = c;
				restart();
			}
		
			
			function init()
			{
				inc = startinc;
				
				canvas = document.getElementById('cw');
				ctx = canvas.getContext('2d');

				dx = width / inc;
				dy = height / inc;
				reds = new Array(dx);
				greens = new Array(dx);
				blues = new Array(dx);

				red_tab = new Array(numcolors);
				green_tab = new Array(numcolors);
				blue_tab = new Array(numcolors);

				if (canvas.getContext)
				{
					var i;
					for (i = 0; i < numcolors; i++)
					{
						var r = Math.floor(Math.random() * 255);
						var g = Math.floor(Math.random() * 255);
						var b = Math.floor(Math.random() * 255);
						red_tab[i] = r;
						green_tab[i] = g;
						blue_tab[i] = b;
					}

					for (x = 0; x < width; x += inc)
					{
						var xx = Math.round(x / inc);

						reds[xx] = new Array(dy);
						greens[xx] = new Array(dy);
						blues[xx] = new Array(dy);

						for (y = 0; y < width; y += inc)
						{
							var colorindex = Math.floor(Math.random() * numcolors);
							var r = red_tab[colorindex];
							var g = green_tab[colorindex];
							var b = blue_tab[colorindex];

							ctx.fillStyle = 'rgb(' + r + ',' + b + ',' + g + ')';
							ctx.fillRect (x, y, inc, inc);

							var yy = Math.round(y / inc);
							reds[xx][yy] = r;
							greens[xx][yy] = g;
							blues[xx][yy] = b;
						}
					}

					interval_id = setInterval(draw,interval_millies);
				}
			}

			function draw()
			{
				if (canvas.getContext)
				{
					var i;
					for (i = 0 ; i < loopcount; i++)
					{
						var xx = Math.floor(Math.random() * dx);
						var yy = Math.floor(Math.random() * dy);

						var x = xx * inc;
						var y = yy * inc;

						var r = reds[xx][yy];
						var g = greens[xx][yy];
						var b = blues[xx][yy];
						ctx.fillStyle = 'rgb(' + r + ',' + b + ',' + g + ')';


						if (xx + 1 < dx)
						{
							ctx.fillRect(x + inc, y, inc, inc);
							reds[xx + 1][yy] = r;
							greens[xx + 1][yy] = g;
							blues[xx + 1][yy] = b;
						}

						if (xx > 0)
						{
							ctx.fillRect(x - inc, y, inc, inc);
							reds[xx - 1][yy] = r;
							greens[xx - 1][yy] = g;
							blues[xx - 1][yy] = b;
						}

						if (yy + 1 < dy)
						{
							ctx.fillRect(x, y + inc, inc, inc);
							reds[xx][yy + 1] = r;
							greens[xx][yy + 1] = g;
							blues[xx][yy + 1] = b;
						}

						if (yy > 0)
						{
							ctx.fillRect(x, y - inc, inc, inc);
							reds[xx][yy - 1] = r;
							greens[xx][yy - 1] = g;
							blues[xx][yy - 1] = b;
						}

					}
				}
			}

		</script>
