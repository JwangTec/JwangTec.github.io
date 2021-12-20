{%- set popular_posts = popular_posts_json(theme.related_posts.params, page) %}
{%- if page.toc.enable and theme.related_posts.enable and (theme.related_posts.display_in_home or not is_index) and popular_posts.json and popular_posts.json.length > 0 %}
<div>
  <ul class="sidebar-related-title">
    <li>
      {{ theme.related_posts.title or __('post.related_posts') }}
    </li>
  </ul>

  <!--noindex-->
  <div class="sidebar-related">
    <ol>
      {%- for popular_post in popular_posts.json %}
      <li><a href="{{ popular_post.path }}" rel="bookmark"><span class="nav-text">{{ popular_post.title }}</span></a></li>
      {%- endfor %}
    </ol>
  </div>
  <!--/noindex-->
</div>
{%- endif %}
