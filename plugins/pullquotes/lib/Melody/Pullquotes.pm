package Melody::Pullquotes;
use strict;
use warnings;

#--- transformer handlers

sub add_pull_quote_field {
    my ( $eh, $app, $param, $tmpl ) = @_;
    return unless $tmpl->isa('MT::Template');
    my $q = $app->can('query') ? $app->query : $app->param;
    my $model = $app->mode('view_page') ? 'page' : 'entry'; # will this work?
    my $pull_quote = '';
    if ( my $id = $q->param('id') ) {
        require MT::Util;
        my $obj
          = $app->model($model)->load( $id, { cached_ok => 1 } );
        $pull_quote = MT::Util::encode_html( $obj->pull_quote )
          if $obj && $obj->pull_quote;
    }
    my $innerHTML
      = qq{ <textarea name="pull_quote" id="pull_quote" class="full-width short" cols="" rows="" mt:watch-change="1">$pull_quote</textarea> };
    my $host_node 
      = $tmpl->getElementById('tags-field')
      or $tmpl->getElementById('text-field')
      or return $app->error('getElementById failed');
    my $block_node = $tmpl->createElement( 'app:setting',
                              { id => 'pull_quote', label => 'pull_quote' } );
    $block_node->innerHTML($innerHTML);
    return $tmpl->insertBefore( $block_node, $host_node )
      or $app->error('failed to insertBefore');
} ## end sub add_pull_quote_field

sub save_pull_quote {
    my ( $cb, $app, $obj, $orig ) = @_;
    my $q = $app->can('query') ? $app->query : $app->param;
    my $pq = $q->param('pull_quote') || '';
    $obj->pull_quote($pq);
}

#--- template tag handlers

sub pull_quote {
    my ( $ctx, $args, $cond ) = @_;
    my $entry = $ctx->stash('entry') or return $ctx->_no_entry_error;
    return $entry->pull_quote || '';
}

1;
