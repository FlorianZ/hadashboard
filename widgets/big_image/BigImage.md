A Dashing widget which shows an image.

To use, in your dashboard.erb file:

    <li data-row="1" data-col="1" data-sizex="3" data-sizey="2">
      <div data-id="picture" data-view="BigImage" data-image="http://i.imgur.com/JycUgrg.jpg"
        style="background-color:transparent;"
        data-max="true"
      ></div>
    </li>

You can update the image via a background job or API key.  Whenever the image laods, the image will be resized to fit the dimensions of the widget.  If `data-max="false"`, then the image will never be enlarged.

This also supports imgur .mp4 and .gifv files.